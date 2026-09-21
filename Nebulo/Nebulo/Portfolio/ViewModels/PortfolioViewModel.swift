//
//  PortfolioViewModel.swift
//  Nebulo
//
//  Created by apprenant152 on 18/09/2026.
//

import Foundation
import Combine

@MainActor
final class PortfolioViewModel: ObservableObject {
    @Published var actions: [Action] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    /// Vrai une fois que le serveur a répondu. Sert à distinguer « portefeuille
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

    private let service: PortfolioServiceProtocol

    // La valeur par défaut est construite dans le corps : évaluée comme
    // argument par défaut, elle le serait hors de l'acteur principal.
    init(service: PortfolioServiceProtocol? = nil) {
        self.service = service ?? PortfolioService()
    }

    /// Les lignes du plus gros dividende encaissé au plus petit : le
    /// portefeuille se lit par ce qu'il rapporte, pas par son ordre de saisie.
    var sortedActions: [Action] {
        actions.sorted { $0.dividendsTotal > $1.dividendsTotal }
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
            actions = try await service.loadPortfolio(token: token)
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
}
