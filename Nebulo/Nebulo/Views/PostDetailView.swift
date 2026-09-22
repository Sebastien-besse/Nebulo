//
//  PostDetailView.swift
//  Nebulo
//
//  Created by apprenant152 on 22/09/2026.
//

import SwiftUI

struct PostDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: PostDetailViewModel
    @FocusState private var isWriting: Bool
    @Environment(\.dismiss) private var dismiss

    /// Appelé quand le message a été supprimé, pour que l'écran d'où l'on
    /// vient se recharge avant de réapparaître : il le montre encore.
    var onPostDeleted: () -> Void = {}

    /// Le ViewModel est injecté, sans valeur par défaut : celle-ci serait
    /// évaluée hors de l'acteur principal. C'est aussi ce qui permet aux
    /// previews d'afficher l'écran rempli, sans jeton ni serveur.
    init(viewModel: PostDetailViewModel, onPostDeleted: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onPostDeleted = onPostDeleted
    }

    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Pas de bouton à droite : répondre se fait en bas de fil,
                // sous les messages auxquels on répond.
                HeaderBar(title: "Réponses")

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            original
                            sectionTitle
                                .padding(.top, 31)
                            thread
                                .padding(.top, 14)
                            composer
                                .padding(.top, 34)
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                    }
                    // Le champ est en bas : sans cela, le clavier le recouvre
                    // au moment même où on s'en sert.
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: viewModel.responses.count) { _, _ in
                        guard let last = viewModel.responses.last else { return }
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
        }
        // La suppression est définitive : elle passe par une confirmation,
        // posée par-dessus l'écran plutôt que par une alerte système, qui ne
        // se style pas.
        .overlay {
            if let pending = viewModel.pendingDeletion {
                ConfirmDialog(
                    title: pending == .post
                        ? "Supprimer le message ?"
                        : "Supprimer la réponse ?",
                    message: pending == .post
                        ? "Il disparaîtra du forum avec toutes ses réponses. C'est définitif."
                        : "Elle disparaîtra du fil pour tout le monde. C'est définitif.",
                    isWorking: viewModel.isDeleting,
                    onCancel: { viewModel.pendingDeletion = nil },
                    onConfirm: { Task { await viewModel.confirmDeletion() } }
                )
                // Le fil se referme derrière elle : la carte disparue, la
                // transition évite un saut sec.
                .transition(.opacity)
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
        // Le message n'existe plus : rester sur son fil n'aurait plus de sens.
        .onChange(of: viewModel.postDeleted) { _, deleted in
            if deleted {
                onPostDeleted()
                dismiss()
            }
        }
    }

    // MARK: Le message d'origine

    /// Le post reprend le violet de la description de Société : c'est le même
    /// rôle, un bloc de contexte qu'on lit avant le reste. Les réponses, elles,
    /// gardent l'orange des cartes du forum.
    private var original: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(viewModel.post.authorFirstname), \(viewModel.post.authorAge) ans")
                    .font(.system(size: 16))
                    .fontWeight(.black)
                    .foregroundStyle(.yellowCustom)
                Spacer(minLength: 0)
                Text(viewModel.post.dateOfCreated.forumBadge)
                    .font(.system(size: 14))
                    .fontWeight(.black)
                    .foregroundStyle(.beige.opacity(0.6))
                    .lineLimit(1)
                // Son propre message : la corbeille se trouve ici comme sur
                // les réponses, plutôt qu'au seul endroit du forum. On
                // supprime là où l'on relit.
                if viewModel.canDeletePost {
                    deleteButton(.post, tint: .beigeClear.opacity(0.55))
                }
            }
            Text(viewModel.post.content)
                .font(.system(size: 14))
                .fontWeight(.medium)
                .foregroundStyle(.beigeClear)
                .lineHeight(.leading(increase: 6))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.purpleClear)
        }
    }

    // MARK: Le fil

    /// Le décompte est écrit à côté du titre : il dit tout de suite si le fil
    /// vaut d'être déroulé.
    private var sectionTitle: some View {
        HStack(spacing: 6) {
            Text("Réponses")
            if viewModel.hasLoaded && viewModel.count > 0 {
                Text("(\(viewModel.count))")
                    .opacity(0.7)
            }
        }
        .font(.system(size: 14))
        .fontWeight(.black)
        .foregroundStyle(.yellowCustom)
        .padding(.leading, 3)
    }

    @ViewBuilder
    private var thread: some View {
        if viewModel.isLoading && viewModel.responses.isEmpty {
            ProgressView()
                .tint(.beigeClear)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
        } else if let error = viewModel.errorMessage, !viewModel.hasLoaded {
            // Le chargement a échoué : l'erreur prend la place du fil. Celles
            // de l'envoi, elles, s'affichent au-dessus du bouton.
            Text(error)
                .font(.system(size: 14))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 24)
        } else if viewModel.responses.isEmpty {
            Text(viewModel.hasLoaded
                 ? "Personne n'a encore répondu. Ouvre le fil."
                 : "Fil indisponible pour le moment.")
                .font(.system(size: 16))
                .foregroundStyle(.beige.opacity(0.7))
                .padding(.vertical, 20)
        } else {
            VStack(spacing: 14) {
                ForEach(viewModel.responses) { response in
                    responseCard(response)
                        .id(response.id)
                }
            }
        }
    }

    private func responseCard(_ response: PostResponse) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(response.authorFirstname), \(response.authorAge) ans")
                    .fontWeight(.black)
                Spacer(minLength: 0)
                Text(response.dateOfCreated.forumBadge)
                    .fontWeight(.black)
                    .opacity(0.6)
                    .lineLimit(1)
                // Le forum est modéré par ses auteurs : la corbeille
                // n'apparaît que sur ses propres réponses.
                if viewModel.isMine(response) {
                    deleteButton(.response(response), tint: .accent.opacity(0.65))
                }
            }
            Text(response.content)
                .fontWeight(.medium)
                .lineHeight(.leading(increase: 6))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.system(size: 14))
        .foregroundStyle(.accent)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.orangeCustom)
        }
    }

    /// Le glyphe est celui du système : l'application n'a pas d'asset de
    /// corbeille, et en dessiner un pour une seule commande serait du poids
    /// pour rien.
    /// La teinte est passée par l'appelant : le message est sur fond violet,
    /// les réponses sur orange, et la même couleur n'y tiendrait pas.
    private func deleteButton(_ target: ThreadDeletion, tint: Color) -> some View {
        Button {
            viewModel.pendingDeletion = target
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(tint)
                // La cible du doigt dépasse le glyphe, qui est petit.
                .frame(width: 30, height: 30)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(target == .post ? "Supprimer mon message" : "Supprimer ma réponse")
    }

    // MARK: Rédaction

    /// La réponse est multiligne : `CustomTextField` ne conviendrait pas, un
    /// `TextEditor` est nécessaire. Le fond du système est masqué pour laisser
    /// passer le crème, et l'invite est posée par-dessus, `TextEditor` n'en
    /// acceptant pas — même montage que l'écran Nouveau post, en plus bas :
    /// on répond en quelques lignes, on n'ouvre pas une discussion.
    private var composer: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 14)
                .fill(.beigeClear)
                .frame(height: 120)
                .overlay(alignment: .topLeading) {
                    ZStack(alignment: .topLeading) {
                        if viewModel.draft.isEmpty {
                            Text("Votre réponse...")
                                .font(.system(size: 18))
                                .fontWeight(.black)
                                .foregroundStyle(.accent.opacity(0.47))
                                .padding(.top, 20)
                                .padding(.leading, 24)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $viewModel.draft)
                            .font(.system(size: 18))
                            .fontWeight(.black)
                            .foregroundStyle(.accent)
                            .scrollContentBackground(.hidden)
                            .focused($isWriting)
                            .padding(.top, 13)
                            .padding(.leading, 19)
                            .padding(.trailing, 16)
                            .padding(.bottom, 12)
                    }
                }
                .frame(height: 120)

            // Le fil s'est chargé : l'erreur qui reste ne peut venir que de
            // l'envoi, et se lit donc à côté du bouton qui l'a déclenché.
            if let error = viewModel.errorMessage, viewModel.hasLoaded {
                Text(error)
                    .font(.system(size: 14))
                    .fontWeight(.black)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 14)
                    .padding(.horizontal, 22)
            }

            ButtonAction(name: viewModel.isSending ? "Envoi…" : "Répondre") {
                isWriting = false
                Task { await viewModel.send() }
            }
            .disabled(viewModel.isSending)
            .opacity(viewModel.isSending ? 0.6 : 1)
            .padding(.top, 24)
        }
    }
}

#Preview {
    let viewModel = PostDetailViewModel(post: fakePosts[0])
    viewModel.responses = fakeResponses
    // Le lecteur est l'auteur du message, et de la dernière réponse : les deux
    // portent la corbeille, le reste du fil non.
    viewModel.viewerId = fakePosts[0].authorId
    viewModel.hasLoaded = true
    viewModel.hasAttemptedLoad = true

    // La pile vit dans ContentView : sans elle ici, le bouton retour n'aurait
    // rien à dépiler.
    return NavigationStack {
        PostDetailView(viewModel: viewModel)
    }
    .environmentObject(AuthViewModel())
}
