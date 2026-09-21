//
//  AddActionView.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import SwiftUI
import CardCarousel

struct AddActionView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: AddActionViewModel
    @Environment(\.dismiss) private var dismiss

    /// Appelé une fois l'action créée, pour que le portefeuille se recharge
    /// avant de réapparaître.
    var onCreated: () -> Void = {}

    /// Le ViewModel est injecté, sans valeur par défaut : celle-ci serait
    /// évaluée hors de l'acteur principal.
    init(viewModel: AddActionViewModel, onCreated: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCreated = onCreated
    }

    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Pas de bouton à droite : la maquette n'en montre aucun.
                    HeaderBar(title: "Action")
                    today
                        .padding(.top, 6)
                    sectors
                        .padding(.top, 14)
                    fields
                        .padding(.top, 22)
                    stepper
                        .padding(.top, 34)
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
        // Le jeton n'est plus accepté : on sort de la session plutôt que
        // d'afficher une erreur que l'utilisateur ne peut pas résoudre.
        .onChange(of: viewModel.sessionExpired) { _, expired in
            if expired { authViewModel.logout() }
        }
    }

    // MARK: Date du jour

    /// Purement indicatif : la maquette date la saisie, mais l'API ne stocke
    /// aucune date de création sur une action.
    private var today: some View {
        Text(Date.now.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year()))
            .font(.system(size: 16))
            .fontWeight(.black)
            .foregroundStyle(.beigeClear.opacity(0.45))
    }

    // MARK: Secteur

    /// Le carrousel décale ses voisines mais ne les estompe pas : la maquette
    /// les pose à 40 %, c'est donc la carte qui s'en charge.
    private var sectors: some View {
        Carousel(
            viewModel.sectors,
            index: $viewModel.sectorIndex,
            sidesScaling: 1
        ) { sector in
            sectorCard(sector)
                .opacity(viewModel.isActive(sector) ? 1 : 0.4)
        }
        .frame(height: 134)
    }

    private func sectorCard(_ sector: Sector) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.orangeCustom)
            .frame(width: 178, height: 95)
            .overlay {
                Text(sector.name)
                    .font(.system(size: 36))
                    .fontWeight(.black)
                    .foregroundStyle(.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 12)
            }
    }

    // MARK: Champs

    private var fields: some View {
        VStack(spacing: 4) {
            CustomTextField(data: $viewModel.name, label: "Nom",
                            widthTextField: 315, heightTextField: 80, fontSize: 24,
                            leadingPadding: 37, capitalization: .words)
            CustomTextField(data: $viewModel.ticker, label: "Ticker",
                            widthTextField: 315, heightTextField: 80, fontSize: 24,
                            leadingPadding: 37, capitalization: .characters)
            CustomTextField(data: $viewModel.value, label: "Valeur",
                            widthTextField: 315, heightTextField: 80, fontSize: 24,
                            leadingPadding: 37, keyboard: .decimalPad)
        }
    }

    // MARK: Quantité

    private var stepper: some View {
        HStack(spacing: 0) {
            roundButton(icon: "IconeLess", width: 38, height: 8) {
                viewModel.decrement()
            }
            Spacer()
            RoundedRectangle(cornerRadius: 14)
                .fill(.beigeClear)
                .frame(width: 109, height: 80)
                .overlay {
                    Text("\(viewModel.quantity)")
                        .font(.system(size: 24))
                        .fontWeight(.black)
                        .foregroundStyle(.accent.opacity(0.47))
                }
            Spacer()
            roundButton(icon: "IconePlus", width: 24, height: 24) {
                viewModel.increment()
            }
        }
        .frame(width: 257)
    }

    /// Le rond orange est dessiné ici : les assets ne portent que le signe.
    /// Le moins est large et plat, le plus est carré — d'où les deux cotes.
    private func roundButton(icon: String, width: CGFloat, height: CGFloat,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(.orangeCustom)
                .frame(width: 58, height: 58)
                .overlay {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)
                }
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
        .disabled(viewModel.isSaving)
        .opacity(viewModel.isSaving ? 0.6 : 1)
    }
}

#Preview {
    // La pile vit dans ContentView : sans elle ici, le bouton retour n'aurait
    // rien à dépiler.
    NavigationStack {
        AddActionView(viewModel: AddActionViewModel())
    }
    .environmentObject(AuthViewModel())
}
