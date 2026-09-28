//
//  AddSharesView.swift
//  Nebulo
//
//  Created by apprenant152 on 24/09/2026.
//

import SwiftUI
import CardCarousel

/// Renforcer une position : acheter de nouveau une société déjà au
/// portefeuille. Cet écran n'a pas de maquette : il reprend le carrousel de
/// l'écran Dividende et le compteur de l'écran Action.
struct AddSharesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: AddSharesViewModel
    @Environment(\.dismiss) private var dismiss

    /// Appelé une fois les actions ajoutées, pour que le portefeuille se
    /// recharge avant de réapparaître.
    var onCreated: () -> Void = {}

    /// Le ViewModel est injecté, sans valeur par défaut : celle-ci serait
    /// évaluée hors de l'acteur principal.
    init(viewModel: AddSharesViewModel, onCreated: @escaping () -> Void = {}) {
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
                    HeaderBar(title: "Renforcer")
                    actions
                        .padding(.top, 20)
                    stepper
                        .padding(.top, 30)
                    preview
                        .padding(.top, 18)
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
            Text("Ajoute d'abord une action : on ne renforce que ce qu'on détient déjà.")
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

    // MARK: Quantité achetée

    /// Le compteur de l'écran Action, aux mêmes cotes. Il compte ce qu'on
    /// achète aujourd'hui, pas ce qu'on détiendra : le total est rappelé
    /// juste dessous.
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

    /// Ce que la ligne portera après l'envoi. Sans ce rappel, le compteur se
    /// lit comme la quantité détenue, et on saisit 14 en pensant corriger 12.
    @ViewBuilder
    private var preview: some View {
        if let action = viewModel.selectedAction, let total = viewModel.totalAfter {
            Text("\(action.quantity) + \(viewModel.quantity) = \(total) actions")
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
    let viewModel = AddSharesViewModel()
    viewModel.actions = fakeActions
    viewModel.quantity = 2
    viewModel.hasAttemptedLoad = true

    // La pile vit dans ContentView : sans elle ici, le bouton retour n'aurait
    // rien à dépiler.
    return NavigationStack {
        AddSharesView(viewModel: viewModel)
    }
    .environmentObject(AuthViewModel())
}
