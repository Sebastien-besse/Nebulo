//
//  PortfolioView.swift
//  Nebulo
//
//  Created by apprenant152 on 18/09/2026.
//

import SwiftUI

/// Les destinations accessibles depuis le portefeuille.
enum PortfolioRoute: Hashable {
    case addAction
    case addDividend(actionId: UUID)
}

struct PortfolioView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: PortfolioViewModel
    @State private var route: PortfolioRoute?

    /// Le ViewModel est injecté, sans valeur par défaut : celle-ci serait
    /// évaluée hors de l'acteur principal. C'est aussi ce qui permet aux
    /// previews d'afficher l'écran rempli, sans jeton ni serveur.
    init(viewModel: PortfolioViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderBar(title: "Portefeuille", trailingIcon: "IconePlus") {
                    route = .addAction
                }
                content
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
        .navigationDestination(item: $route) { destination in
            switch destination {
            case .addAction:
                // La liste se recharge avant de réapparaître : la nouvelle
                // ligne doit être là au retour.
                AddActionView(viewModel: AddActionViewModel()) {
                    Task { await viewModel.load() }
                }
            case .addDividend(let actionId):
                // Le cumul de la ligne change à l'instant où le dividende
                // est enregistré : la liste doit repartir du serveur.
                AddDividendView(
                    viewModel: AddDividendViewModel(preselectedActionId: actionId)
                ) {
                    Task { await viewModel.load() }
                }
            }
        }
    }

    // MARK: Contenu

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.actions.isEmpty {
            Spacer()
            ProgressView()
                .tint(.beigeClear)
            Spacer()
        } else if let error = viewModel.errorMessage {
            Spacer()
            Text(error)
                .font(.system(size: 16))
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        } else if viewModel.hasLoaded && viewModel.actions.isEmpty {
            Spacer()
            emptyState
            Spacer()
        } else {
            ScrollView {
                // Le conteneur laisse les verres voisins se fondre entre eux
                // quand ils se rapprochent, au lieu de se superposer chacun
                // dans son coin. Son espacement doit suivre celui de la pile.
                GlassEffectContainer(spacing: 20) {
                    VStack(spacing: 20) {
                        ForEach(viewModel.sortedActions) { action in
                            InvestCard(action: action) {
                                route = .addDividend(actionId: action.id)
                            }
                        }
                    }
                }
                .padding(.top, 31)
                .padding(.bottom, 24)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("Portefeuille vide")
                .font(.system(size: 20))
                .fontWeight(.black)
                .foregroundStyle(.yellowCustom)
            Text("Ajoute ta première action pour commencer à encaisser des dividendes.")
                .font(.system(size: 16))
                .foregroundStyle(.beige)
                .opacity(0.8)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    // La pile vit dans ContentView : sans elle ici, le bouton retour n'aurait
    // rien à dépiler.
    let viewModel = PortfolioViewModel()
    viewModel.actions = fakeActions
    viewModel.hasLoaded = true
    viewModel.hasAttemptedLoad = true

    return NavigationStack {
        PortfolioView(viewModel: viewModel)
    }
    .environmentObject(AuthViewModel())
}
