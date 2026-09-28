//
//  AddSharesViewModel.swift
//  Nebulo
//
//  Created by apprenant152 on 24/09/2026.
//

import Foundation
import Combine

/// Renforcer une position : acheter de nouveau une société déjà détenue.
///
/// L'écran ne redemande ni le nom, ni le ticker, ni le secteur : ils sont
/// déjà sur la ligne. Seule la quantité achetée se saisit, et le serveur
/// l'additionne à celle qui existe.
@MainActor
final class AddSharesViewModel: ObservableObject {
    /// Action sur laquelle l'écran s'ouvre, quand il est appelé depuis une
    /// carte du portefeuille.
    private let preselectedActionId: UUID?

    @Published var actions: [Action] = []
    /// Action au centre du carrousel.
    @Published var actionIndex: Int = 0
    /// Nombre d'actions achetées, pas le nouveau total : c'est un ajout.
    @Published var quantity: Int = 1

    @Published var isLoading: Bool = false
    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil
    /// Vrai dès qu'un chargement a été tenté, abouti ou non. Les previews le
    /// mettent à vrai pour que l'écran n'aille jamais toucher le trousseau ni
    /// le réseau, dont elles ne disposent pas.
    @Published var hasAttemptedLoad: Bool = false
    /// Vrai quand le jeton n'est plus accepté : l'écran demande alors une
    /// déconnexion plutôt que d'afficher une erreur insoluble.
    @Published var sessionExpired: Bool = false

    private let service: PortfolioServiceProtocol

    /// Le jeton est relu à chaque appel, jamais retenu : une déconnexion le
    /// retire, et le ViewModel, lui, survit.
    ///
    /// Injectable pour que les tests n'aient pas à écrire dans le trousseau du
    /// hôte, qu'ils partagent avec ceux de `TokenStore`.
    private let tokenProvider: () -> String?

    // Les valeurs par défaut sont construites dans le corps : évaluées comme
    // arguments par défaut, elles le seraient hors de l'acteur principal.
    init(preselectedActionId: UUID? = nil, service: PortfolioServiceProtocol? = nil,
         tokenProvider: (() -> String?)? = nil) {
        self.preselectedActionId = preselectedActionId
        self.service = service ?? PortfolioService()
        self.tokenProvider = tokenProvider ?? { TokenStore.shared.token }
    }

    var selectedAction: Action? {
        actions.indices.contains(actionIndex) ? actions[actionIndex] : nil
    }

    /// Vrai pour la carte au centre. Le carrousel n'estompe pas ses voisines
    /// lui-même : il ne fait que les décaler.
    func isActive(_ action: Action) -> Bool {
        selectedAction?.id == action.id
    }

    /// Ce que la ligne portera après l'envoi. Le montrer avant évite de
    /// confondre « j'achète 2 » avec « j'en ai 2 ».
    var totalAfter: Int? {
        guard let action = selectedAction else { return nil }
        return action.quantity + quantity
    }

    /// Le compteur ne descend pas sous un : renforcer de zéro action ne veut
    /// rien dire, et le serveur refuse la quantité nulle.
    func decrement() {
        quantity = max(1, quantity - 1)
    }

    func increment() {
        quantity += 1
    }

    func load() async {
        hasAttemptedLoad = true
        guard let token = tokenProvider() else {
            sessionExpired = true
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            actions = try await service.loadPortfolio(token: token)
            // L'écran s'ouvre sur l'action d'où l'on vient, pas sur la première.
            if let preselectedActionId,
               let index = actions.firstIndex(where: { $0.id == preselectedActionId }) {
                actionIndex = index
            }
        } catch APIError.httpError(let statusCode, _) where statusCode == 401 {
            sessionExpired = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isLoading = false
    }

    /// Renvoie vrai quand l'enregistrement a abouti, pour que l'écran sache
    /// se refermer.
    func save() async -> Bool {
        guard let action = selectedAction else {
            errorMessage = "Choisis une action"
            return false
        }
        guard quantity > 0 else {
            errorMessage = "Indique combien d'actions tu as achetées"
            return false
        }
        guard let token = tokenProvider() else {
            sessionExpired = true
            return false
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            _ = try await service.addShares(to: action, quantity: quantity, token: token)
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
}
