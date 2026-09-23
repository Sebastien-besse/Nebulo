//
//  SocietyViewModel.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation
import Combine

@MainActor
final class SocietyViewModel: ObservableObject {
    let companyId: UUID

    @Published var company: Company? = nil
    /// Le fil de l'entreprise, chronologique côté serveur.
    @Published var posts: [Post] = []
    /// Carte au centre du carrousel. Les voisines s'estompent, comme dans la
    /// maquette où elles ne sont qu'à 24 %.
    @Published var activeIndex: Int = 0
    /// Le commentaire en cours d'écriture, dans le modal.
    @Published var commentDraft: String = ""
    /// Vrai pendant la publication : le modal éteint ses boutons.
    @Published var isPublishing: Bool = false
    /// L'erreur de publication, distincte de celle du chargement : elle se lit
    /// dans le modal, à côté du bouton qui l'a déclenchée.
    @Published var publishError: String? = nil

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    /// Vrai une fois que le serveur a répondu. Sert à distinguer « aucun
    /// message » d'un chargement qui a échoué : les deux laissent la liste
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
    init(companyId: UUID, service: SocietyServiceProtocol? = nil) {
        self.companyId = companyId
        self.service = service ?? SocietyService()
    }

    /// Vrai pour la carte au centre. Le carrousel n'estompe pas ses voisines
    /// lui-même : il ne fait que les décaler.
    func isActive(_ post: Post) -> Bool {
        guard posts.indices.contains(activeIndex) else { return false }
        return posts[activeIndex].id == post.id
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
            let (company, posts) = try await service.loadSociety(companyId: companyId, token: token)
            self.company = company
            self.posts = posts
            // Un rechargement peut rendre le fil plus court qu'avant — un
            // message supprimé depuis son écran de réponses. L'index resterait
            // alors sur une carte qui n'existe plus.
            self.activeIndex = min(activeIndex, max(0, posts.count - 1))
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

    /// Publie le commentaire en cours sur l'entreprise affichée.
    ///
    /// Renvoie vrai quand le serveur a accepté, pour que l'écran sache
    /// refermer le modal. Le fil est rechargé plutôt que complété sur place :
    /// c'est le serveur qui décide de l'ordre des cartes, et deviner où glisser
    /// la nouvelle reviendrait à réécrire ce tri ici.
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
            _ = try await service.createComment(
                content: content,
                companyId: companyId,
                token: token
            )
            // Vidé seulement une fois le serveur d'accord : sur un échec, le
            // texte reste dans le champ plutôt que d'être perdu.
            commentDraft = ""
            await load()
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
