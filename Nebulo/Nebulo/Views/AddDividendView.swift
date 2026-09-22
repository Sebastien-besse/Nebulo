//
//  AddDividendView.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import SwiftUI
import CardCarousel

/// Saisie d'un dividende encaissé. Cet écran n'a pas de maquette : il reprend
/// les cotes et les composants des deux autres formulaires, Action et Post.
struct AddDividendView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: AddDividendViewModel
    @Environment(\.dismiss) private var dismiss

    /// Appelé une fois le dividende enregistré, pour que le portefeuille se
    /// recharge avant de réapparaître.
    var onCreated: () -> Void = {}

    /// Le ViewModel est injecté, sans valeur par défaut : celle-ci serait
    /// évaluée hors de l'acteur principal.
    init(viewModel: AddDividendViewModel, onCreated: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCreated = onCreated
    }

    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Pas de bouton à droite : rien à ajouter depuis un écran
                    // qui sert déjà à ajouter.
                    HeaderBar(title: "Dividende")
                    actions
                        .padding(.top, 20)
                    perShareField
                        .padding(.top, 22)
                    dateField
                        .padding(.top, 4)
                    preview
                        .padding(.top, 10)
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .fontWeight(.black)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 14)
                            .padding(.horizontal, 40)
                    }
                    submit
                        .padding(.top, 34)
                }
                .padding(.bottom, 32)
            }
        }
        // L'écran a son propre bouton retour, dessiné dans l'en-tête.
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            // Une preview arrive avec son état déjà posé : ne rien aller
            // chercher, elle n'a ni trousseau ni réseau.
            if !viewModel.hasAttemptedLoad { await viewModel.load() }
        }
        // Le jeton n'est plus accepté : on sort de la session plutôt que
        // d'afficher une erreur que l'utilisateur ne peut pas résoudre.
        .onChange(of: viewModel.sessionExpired) { _, expired in
            if expired { authViewModel.logout() }
        }
    }

    // MARK: Action

    /// Le carrousel décale ses voisines mais ne les estompe pas : les autres
    /// formulaires les posent à 40 %, c'est donc la carte qui s'en charge.
    @ViewBuilder
    private var actions: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(.beigeClear)
                .frame(height: 134)
        } else if viewModel.actions.isEmpty {
            Text("Ajoute d'abord une action : un dividende est toujours versé par l'une d'elles.")
                .font(.system(size: 14))
                .foregroundStyle(.beige.opacity(0.7))
                .multilineTextAlignment(.center)
                .frame(height: 134)
                .padding(.horizontal, 40)
        } else {
            Carousel(
                viewModel.actions,
                index: $viewModel.actionIndex,
                sidesScaling: 1
            ) { action in
                actionCard(action)
                    .opacity(viewModel.isActive(action) ? 1 : 0.4)
            }
            .frame(height: 134)
        }
    }

    private func actionCard(_ action: Action) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.orangeCustom)
            .frame(width: 178, height: 95)
            .overlay {
                VStack(spacing: 0) {
                    Text(action.name)
                        .font(.system(size: 28))
                        .fontWeight(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                    Text("\(action.quantity) actions")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                }
                .foregroundStyle(.accent)
                .padding(.horizontal, 12)
            }
    }

    // MARK: Champs

    private var perShareField: some View {
        CustomTextField(data: $viewModel.perShare, label: "Montant par action",
                        widthTextField: 315, heightTextField: 80, fontSize: 24,
                        leadingPadding: 37, keyboard: .decimalPad)
    }

    /// La date de versement, pas celle de la saisie. Le serveur horodate la
    /// seconde de son côté en UTC, et ce sont deux notions distinctes : l'une
    /// alimente les cumuls mensuels, l'autre les fenêtres de challenge.
    private var dateField: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(.beigeClear)
            .frame(width: 315, height: 80)
            .overlay {
                HStack(spacing: 0) {
                    Text("Versé le")
                        .font(.system(size: 24))
                        .fontWeight(.black)
                        .foregroundStyle(.accent.opacity(0.47))
                    Spacer()
                    // Un versement à venir n'a pas été encaissé : la borne
                    // haute est aujourd'hui.
                    DatePicker("", selection: $viewModel.paymentDate,
                               in: ...Date.now, displayedComponents: .date)
                        .labelsHidden()
                        .tint(.orangeCustom)
                }
                .padding(.leading, 37)
                .padding(.trailing, 16)
            }
            .frame(width: 315, height: 98)
    }

    /// Ce que le serveur figera sur la ligne, montré avant l'envoi : le total
    /// ne se recalculera plus jamais, autant le voir tant qu'on peut encore
    /// corriger.
    @ViewBuilder
    private var preview: some View {
        if let label = viewModel.previewLabel {
            Text(label)
                .font(.system(size: 14))
                .fontWeight(.black)
                .foregroundStyle(.yellowCustom)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
    }

    // MARK: Validation

    private var submit: some View {
        ButtonAction(name: viewModel.isSaving ? "Envoi…" : "Ajouter") {
            Task {
                if await viewModel.save() {
                    onCreated()
                    dismiss()
                }
            }
        }
        .disabled(viewModel.isSaving || viewModel.actions.isEmpty)
        .opacity(viewModel.isSaving || viewModel.actions.isEmpty ? 0.6 : 1)
    }
}

#Preview {
    let viewModel = AddDividendViewModel()
    viewModel.actions = fakeActions
    viewModel.perShare = "3,20"
    viewModel.hasAttemptedLoad = true

    // La pile vit dans ContentView : sans elle ici, le bouton retour n'aurait
    // rien à dépiler.
    return NavigationStack {
        AddDividendView(viewModel: viewModel)
    }
    .environmentObject(AuthViewModel())
}
