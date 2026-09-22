//
//  PostDetailViewModel.swift
//  Nebulo
//
//  Created by apprenant152 on 22/09/2026.
//

import Foundation
import Combine

/// Ce dont la suppression attend confirmation sur l'écran d'un fil : le
/// message lui-même, ou l'une de ses réponses. Les deux ne peuvent pas être
/// en attente en même temps — une seule boîte de dialogue s'ouvre.
enum ThreadDeletion: Equatable {
    case post
    case response(PostResponse)
}

@MainActor
final class PostDetailViewModel: ObservableObject {
    /// Le message ouvert. Il arrive entier de l'écran appelant : le recharger
    /// ne dirait rien de neuf, et ferait un aller-retour de plus à l'ouverture.
    let post: Post

    /// Les réponses, dans l'ordre où elles ont été écrites.
    @Published var responses: [PostResponse] = []
    /// La réponse en cours de rédaction.
    @Published var draft: String = ""
    /// Le lecteur. Sert à ne proposer la corbeille que sur ses propres
    /// réponses — les previews le posent à la main.
    @Published var viewerId: UUID? = nil
    /// Ce dont la suppression attend confirmation. Nil le reste du temps : la
    /// suppression est définitive, elle ne part pas sur un toucher.
    @Published var pendingDeletion: ThreadDeletion? = nil
    /// Vrai une fois le message supprimé : l'écran n'a plus rien à montrer et
    /// se referme sur le fil d'où il vient.
    @Published var postDeleted: Bool = false

    @Published var isLoading: Bool = false
    @Published var isSending: Bool = false
    @Published var isDeleting: Bool = false
    @Published var errorMessage: String? = nil
    /// Vrai une fois que le serveur a répondu. Sert à distinguer « aucune
    /// réponse » d'un chargement qui a échoué : les deux laissent la liste
    /// vide, mais ne se disent pas de la même façon.
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
    init(post: Post, service: ForumServiceProtocol? = nil) {
        self.post = post
        self.service = service ?? ForumService()
    }

    /// Le décompte affiché vient de la liste chargée, pas du `responseCount`
    /// du post : celui-ci a été compté avant que le fil ne s'ouvre, et une
    /// réponse écrite ici le laisserait en retard d'une unité.
    var count: Int { responses.count }

    /// Vrai sur ses propres réponses. Faux tant que le lecteur est inconnu :
    /// mieux vaut une corbeille qui manque qu'une qui trompe.
    func isMine(_ response: PostResponse) -> Bool {
        guard let viewerId else { return false }
        return response.authorId == viewerId
    }

    /// Même règle pour le message en tête d'écran.
    var canDeletePost: Bool {
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
            let (viewerId, responses) = try await service.loadThread(postId: post.id, token: token)
            self.viewerId = viewerId
            self.responses = responses
            hasLoaded = true
        } catch APIError.httpError(let statusCode, _) where statusCode == 401 {
            sessionExpired = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isLoading = false
    }

    /// Publie la réponse en cours et l'ajoute en fin de fil — l'API la renvoie
    /// créée, il n'y a donc rien à recharger.
    ///
    /// Renvoie vrai quand l'envoi a abouti, pour que l'écran sache descendre
    /// jusqu'au message qu'il vient d'ajouter.
    @discardableResult
    func send() async -> Bool {
        let content = draft.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !content.isEmpty else {
            errorMessage = "La réponse ne peut pas être vide"
            return false
        }
        guard let token = TokenStore.shared.token else {
            sessionExpired = true
            return false
        }

        isSending = true
        errorMessage = nil
        defer { isSending = false }

        do {
            let created = try await service.createResponse(content: content, postId: post.id, token: token)
            responses.append(created)
            // Vidé seulement une fois le serveur d'accord : sur un échec, le
            // texte reste dans le champ plutôt que d'être perdu.
            draft = ""
            return true
        } catch APIError.httpError(let statusCode, _) where statusCode == 401 {
            sessionExpired = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        return false
    }

    /// Retire ce dont la suppression a été confirmée — le message ou l'une de
    /// ses réponses.
    ///
    /// Le cahier des charges ne prévoit pas de modification : un message
    /// publié ne se réécrit pas sous les réponses qu'il a reçues. La
    /// suppression est donc le seul retour en arrière, et elle est définitive
    /// — d'où la confirmation qui la précède.
    func confirmDeletion() async {
        guard let target = pendingDeletion else { return }
        guard let token = TokenStore.shared.token else {
            sessionExpired = true
            return
        }

        isDeleting = true
        errorMessage = nil
        defer { isDeleting = false }

        do {
            switch target {
            case .post:
                try await service.deletePost(id: post.id, token: token)
                // L'écran se referme : le fil affiché n'existe plus, et ses
                // réponses sont tombées avec lui en CASCADE.
                postDeleted = true
            case .response(let response):
                try await service.deleteResponse(id: response.id, token: token)
                responses.removeAll { $0.id == response.id }
            }
            pendingDeletion = nil
        } catch APIError.httpError(let statusCode, _) where statusCode == 401 {
            sessionExpired = true
        } catch APIError.httpError(let statusCode, _) where statusCode == 404 {
            // Déjà supprimé ailleurs : s'aligner sur la base plutôt que
            // d'annoncer une erreur pour un fil désormais juste.
            switch target {
            case .post:
                postDeleted = true
            case .response(let response):
                responses.removeAll { $0.id == response.id }
            }
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
