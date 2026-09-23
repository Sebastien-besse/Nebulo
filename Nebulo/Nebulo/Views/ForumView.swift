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
    /// Le fil de réponses d'un message. Le post est transporté entier :
    /// l'écran l'affiche en tête, et le recharger ne dirait rien de neuf.
    case thread(Post)
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
        // La suppression est définitive : elle passe par une confirmation,
        // posée par-dessus l'écran plutôt que par une alerte système, qui ne
        // se style pas.
        .overlay {
            if let pending = viewModel.pendingDeletion {
                ConfirmDialog(
                    title: "Supprimer le message ?",
                    message: "Il disparaîtra du forum avec toutes ses réponses. C'est définitif.",
                    isWorking: viewModel.isDeleting,
                    onCancel: { viewModel.pendingDeletion = nil },
                    onConfirm: { Task { await viewModel.confirmDeletion() } }
                )
                .transition(.opacity)
                .id(pending.id)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.pendingDeletion)
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
        // De retour d'un écran poussé. Le forum est vivant tant qu'il est
        // dessous, donc son `task` ne se rejoue pas — or une réponse a pu
        // être écrite dans le fil, ou dans celui d'une société, et le
        // décompte des cartes en dépend.
        //
        // Un chargement déjà lancé tient : la suppression d'un message et
        // l'ajout d'un autre rechargent avant de dépiler, pour que la liste
        // soit à jour au moment où elle réapparaît.
        .onChange(of: route) { _, destination in
            guard destination == nil, !viewModel.isLoading else { return }
            Task { await viewModel.load() }
        }
        .navigationDestination(item: $route) { destination in
            switch destination {
            case .society(let companyId):
                SocietyView(viewModel: SocietyViewModel(companyId: companyId))
            case .thread(let post):
                // Le fil se recharge avant de réapparaître : le message
                // supprimé y figure encore.
                PostDetailView(viewModel: PostDetailViewModel(post: post)) {
                    Task { await viewModel.load() }
                }
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
            ScrollView(showsIndicators: false) {
                // Le conteneur laisse les verres voisins se fondre entre eux
                // quand ils se rapprochent. Son espacement suit celui de la
                // pile, 34 dans la maquette.
                GlassEffectContainer(spacing: 34) {
                    VStack(spacing: 34) {
                        ForEach(viewModel.posts) { post in
                            CorporateCard(
                                post: post,
                                canVote: viewModel.canVote(on: post),
                                canDelete: viewModel.canDelete(post),
                                onVote: { value in
                                    Task { await viewModel.vote(value, on: post) }
                                },
                                onDelete: { viewModel.pendingDeletion = post },
                                // La fiche société n'existe pas pour un
                                // message sans entreprise : son toucher
                                // déroule alors son fil, qui serait sinon
                                // hors d'atteinte.
                                onOpen: {
                                    if let id = post.companyId {
                                        route = .society(companyId: id)
                                    } else {
                                        route = .thread(post)
                                    }
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
