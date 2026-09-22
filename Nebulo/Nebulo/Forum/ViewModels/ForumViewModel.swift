//
//  ForumViewModel.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation
import Combine

@MainActor
final class ForumViewModel: ObservableObject {
    /// Le fil arrive déjà antéchronologique du serveur : le réordonner ici
    /// ferait diverger l'écran de ce que l'API considère comme l'ordre.
    @Published var posts: [Post] = []
    /// Identifiant du lecteur : il éteint les votes sur ses propres posts, et
    /// c'est sur eux seuls qu'apparaît la corbeille.
    @Published var viewerId: UUID? = nil
    /// Le message dont la suppression attend confirmation. Nil le reste du
    /// temps : la suppression est définitive, elle ne part pas sur un toucher.
    @Published var pendingDeletion: Post? = nil
    @Published var isDeleting: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    /// Vrai une fois que le serveur a répondu. Sert à distinguer « forum
    /// vide » d'un chargement qui a échoué : les deux laissent la liste vide,
    /// mais ne se disent pas de la même façon.
    @Published var hasLoaded: Bool = false
    /// Vrai dès qu'un chargement a été tenté, abouti ou non. Les previews le
    /// mettent à vrai pour que l'écran n'aille jamais toucher le trousseau ni
    /// le réseau, dont elles ne disposent pas.
    @Published var hasAttemptedLoad: Bool = false
    /// Vrai quand le jeton n'est plus accepté : l'écran demande alors une
    /// déconnexion plutôt que d'afficher une erreur insoluble.
    @Published var sessionExpired: Bool = false

    private let service: ForumServiceProtocol

    // La valeur par défaut est construite dans le corps : évaluée comme
    // argument par défaut, elle le serait hors de l'acteur principal.
    init(service: ForumServiceProtocol? = nil) {
        self.service = service ?? ForumService()
    }

    /// Nul ne vote sur son propre message, l'API renvoie 403.
    func canVote(on post: Post) -> Bool {
        post.authorId != viewerId
    }

    /// L'inverse du vote : le forum est modéré par ses auteurs, chacun ne
    /// retire que ce qu'il a écrit. Faux tant que le lecteur est inconnu —
    /// mieux vaut une corbeille qui manque qu'une qui trompe.
    func canDelete(_ post: Post) -> Bool {
        guard let viewerId else { return false }
        return post.authorId == viewerId
    }

    func load() async {
        hasAttemptedLoad = true
        guard let token = TokenStore.shared.token else {
            sessionExpired = true
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let (viewerId, posts) = try await service.loadForum(token: token)
            self.viewerId = viewerId
            self.posts = posts
            self.hasLoaded = true
        } catch APIError.httpError(let statusCode, _) where statusCode == 401 {
            sessionExpired = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isLoading = false
    }

    /// Le serveur répond avec le post recompté : seule cette ligne est
    /// remplacée, le reste du fil ne bouge pas et la position de lecture
    /// est préservée.
    func vote(_ value: VoteType, on post: Post) async {
        guard canVote(on: post) else { return }
        guard let token = TokenStore.shared.token else {
            sessionExpired = true
            return
        }
        errorMessage = nil
        do {
            let updated = try await service.toggleVote(value, on: post, token: token)
            if let index = posts.firstIndex(where: { $0.id == updated.id }) {
                posts[index] = updated
            }
        } catch APIError.httpError(let statusCode, _) where statusCode == 401 {
            sessionExpired = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
    }

    /// Retire le message dont la suppression a été confirmée.
    ///
    /// Ses réponses partent avec lui : la clé étrangère de `responses` est en
    /// CASCADE. Rien ne se modifie dans ce forum — la suppression est le seul
    /// retour en arrière, et elle est définitive.
    func confirmDeletion() async {
        guard let post = pendingDeletion else { return }
        guard let token = TokenStore.shared.token else {
            sessionExpired = true
            return
        }

        isDeleting = true
        errorMessage = nil
        defer { isDeleting = false }

        do {
            try await service.deletePost(id: post.id, token: token)
            posts.removeAll { $0.id == post.id }
            pendingDeletion = nil
        } catch APIError.httpError(let statusCode, _) where statusCode == 401 {
            sessionExpired = true
        } catch APIError.httpError(let statusCode, _) where statusCode == 404 {
            // Déjà supprimé ailleurs : le retirer de l'écran plutôt que
            // d'annoncer une erreur pour un fil désormais juste.
            posts.removeAll { $0.id == post.id }
            pendingDeletion = nil
        } catch let error as APIError {
            errorMessage = error.errorDescription
            pendingDeletion = nil
        } catch {
            errorMessage = "Une erreur est survenue"
            pendingDeletion = nil
        }
    }
}
