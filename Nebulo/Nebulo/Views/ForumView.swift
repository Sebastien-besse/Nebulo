//
//  ForumView.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import SwiftUI

/// Les destinations accessibles depuis le forum.
enum ForumRoute: Hashable {
    case society(companyId: UUID)
    case addPost
}

struct ForumView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: ForumViewModel
    @State private var route: ForumRoute?

    /// Le ViewModel est injecté, sans valeur par défaut : celle-ci serait
    /// évaluée hors de l'acteur principal. C'est aussi ce qui permet aux
    /// previews d'afficher l'écran rempli, sans jeton ni serveur.
    init(viewModel: ForumViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Écart assumé : la maquette ne pose aucun bouton ici, mais
                // l'écran de rédaction ne serait alors accessible de nulle part.
                HeaderBar(title: "Forum", trailingIcon: "IconePlus") {
                    route = .addPost
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
            case .society(let companyId):
                SocietyView(viewModel: SocietyViewModel(companyId: companyId))
            case .addPost:
                // Le fil se recharge avant de réapparaître : le nouveau
                // message doit être en tête au retour.
                AddPostView(viewModel: AddPostViewModel()) {
                    Task { await viewModel.load() }
                }
            }
        }
    }

    // MARK: Contenu

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.posts.isEmpty {
            Spacer()
            ProgressView()
                .tint(.beigeClear)
            Spacer()
        } else if let error = viewModel.errorMessage, viewModel.posts.isEmpty {
            Spacer()
            Text(error)
                .font(.system(size: 16))
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        } else if viewModel.hasLoaded && viewModel.posts.isEmpty {
            Spacer()
            emptyState
            Spacer()
        } else {
            ScrollView {
                // Le conteneur laisse les verres voisins se fondre entre eux
                // quand ils se rapprochent. Son espacement suit celui de la
                // pile, 34 dans la maquette.
                GlassEffectContainer(spacing: 34) {
                    VStack(spacing: 34) {
                        ForEach(viewModel.posts) { post in
                            CorporateCard(
                                post: post,
                                canVote: viewModel.canVote(on: post),
                                onVote: { value in
                                    Task { await viewModel.vote(value, on: post) }
                                },
                                // Un message sans entreprise n'ouvre rien :
                                // la fiche société n'existe pas pour lui.
                                onOpen: post.companyId.map { id in
                                    { route = .society(companyId: id) }
                                }
                            )
                        }
                    }
                }
                // L'écart entre le titre et la première carte est plus large
                // ici que sur le portefeuille : la maquette pose 69.
                .padding(.top, 69)
                .padding(.bottom, 24)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("Forum vide")
                .font(.system(size: 20))
                .fontWeight(.black)
                .foregroundStyle(.yellowCustom)
            Text("Personne n'a encore ouvert de discussion. Lance la première.")
                .font(.system(size: 16))
                .foregroundStyle(.beige)
                .opacity(0.8)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    let viewModel = ForumViewModel()
    viewModel.posts = fakePosts
    viewModel.viewerId = fakePosts.last!.authorId
    viewModel.hasLoaded = true
    viewModel.hasAttemptedLoad = true

    // La pile vit dans ContentView : sans elle ici, le bouton retour n'aurait
    // rien à dépiler.
    return NavigationStack {
        ForumView(viewModel: viewModel)
    }
    .environmentObject(AuthViewModel())
}
