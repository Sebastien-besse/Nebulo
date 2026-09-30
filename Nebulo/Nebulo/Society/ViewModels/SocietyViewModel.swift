//
//  SocietyViewModel.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation
import Combine

/// La page d'un post du forum : la fiche de son entreprise, et ses
/// commentaires en carrousel. Chaque commentaire a ses propres réponses, dans
/// son fil.
@MainActor
final class SocietyViewModel: ObservableObject {
    /// Le post touché dans le forum. C'est lui que le + commente.
    let post: Post

    @Published var company: Company? = nil
    /// Les commentaires du post, chronologiques côté serveur.
    @Published var comments: [Post] = []
    /// Carte au centre du carrousel. Les voisines s'estompent, comme dans la
    /// maquette où elles ne sont qu'à 24 %.
    @Published var activeIndex: Int = 0
    /// Le commentaire en cours d'écriture, dans la feuille.
    @Published var commentDraft: String = ""
    /// Vrai pendant la publication : la feuille éteint ses boutons.
    @Published var isPublishing: Bool = false
    /// L'erreur de publication, distincte de celle du chargement : elle se lit
    /// dans la feuille, à côté du bouton qui l'a déclenchée.
    @Published var publishError: String? = nil

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    /// Vrai une fois que le serveur a répondu. Sert à distinguer « aucun
    /// commentaire » d'un chargement qui a échoué : les deux laissent la liste
    /// vide, mais ne se disent pas de la même façon.
    @Published var hasLoaded: Bool = false
    /// Vrai dès qu'un chargement a été tenté, abouti ou non. Les previews le
    /// mettent à vrai pour que l'écran n'aille jamais toucher le trousseau ni
    /// le réseau, dont elles ne disposent pas.
    @Published var hasAttemptedLoad: Bool = false
    /// Vrai quand le jeton n'est plus accepté : l'écran demande alors une
    /// déconnexion plutôt que d'afficher une erreur insoluble.
    @Published var sessionExpired: Bool = false

    private let service: SocietyServiceProtocol

    // La valeur par défaut est construite dans le corps : évaluée comme
    // argument par défaut, elle le serait hors de l'acteur principal.
    init(post: Post, service: SocietyServiceProtocol? = nil) {
        self.post = post
        self.service = service ?? SocietyService()
    }

    /// Vrai pour la carte au centre. Le carrousel n'estompe pas ses voisines
    /// lui-même : il ne fait que les décaler.
    func isActive(_ comment: Post) -> Bool {
        guard comments.indices.contains(activeIndex) else { return false }
        return comments[activeIndex].id == comment.id
    }

    func load() async {
        hasAttemptedLoad = true
        // Un post sans entreprise n'a pas de fiche : le forum ouvre alors son
        // fil, jamais cet écran.
        guard let companyId = post.companyId else { return }
        guard let token = TokenStore.shared.token else {
            sessionExpired = true
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let (company, comments) = try await service.loadSociety(
                companyId: companyId,
                postId: post.id,
                token: token
            )
            self.company = company
            self.comments = comments
            // Un rechargement peut rendre la liste plus courte qu'avant — un
            // commentaire supprimé depuis son fil. L'index resterait alors sur
            // une carte qui n'existe plus.
            self.activeIndex = min(activeIndex, max(0, comments.count - 1))
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

    /// Publie le commentaire en cours sur le post : une nouvelle carte du
    /// carrousel.
    ///
    /// Renvoie vrai quand le serveur a accepté, pour que l'écran sache
    /// refermer la feuille. La liste est rechargée puis centrée sur le
    /// nouveau commentaire : on voit où il a atterri.
    @discardableResult
    func publishComment() async -> Bool {
        let content = commentDraft.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !content.isEmpty else {
            publishError = "Le commentaire ne peut pas être vide"
            return false
        }
        guard let token = TokenStore.shared.token else {
            sessionExpired = true
            return false
        }

        isPublishing = true
        publishError = nil
        defer { isPublishing = false }

        do {
            let created = try await service.createComment(
                content: content,
                postId: post.id,
                token: token
            )
            // Vidé seulement une fois le serveur d'accord : sur un échec, le
            // texte reste dans le champ plutôt que d'être perdu.
            commentDraft = ""
            await load()
            if let index = comments.firstIndex(where: { $0.id == created.id }) {
                activeIndex = index
            }
            return true
        } catch APIError.httpError(let statusCode, _) where statusCode == 401 {
            sessionExpired = true
        } catch let error as APIError {
            publishError = error.errorDescription
        } catch {
            publishError = "Une erreur est survenue"
        }
        return false
    }
}
