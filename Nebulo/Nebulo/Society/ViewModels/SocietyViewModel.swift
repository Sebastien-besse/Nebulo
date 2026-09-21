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
}
