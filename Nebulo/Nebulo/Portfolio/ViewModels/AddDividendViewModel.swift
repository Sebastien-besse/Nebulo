//
//  AddDividendViewModel.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation
import Combine

@MainActor
final class AddDividendViewModel: ObservableObject {
    /// Action sur laquelle l'écran s'ouvre, quand il est appelé depuis une
    /// carte du portefeuille.
    private let preselectedActionId: UUID?

    @Published var actions: [Action] = []
    /// Action au centre du carrousel.
    @Published var actionIndex: Int = 0
    @Published var perShare: String = ""
    @Published var paymentDate: Date = .now

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

    // La valeur par défaut est construite dans le corps : évaluée comme
    // argument par défaut, elle le serait hors de l'acteur principal.
    init(preselectedActionId: UUID? = nil, service: PortfolioServiceProtocol? = nil) {
        self.preselectedActionId = preselectedActionId
        self.service = service ?? PortfolioService()
    }

    var selectedAction: Action? {
        actions.indices.contains(actionIndex) ? actions[actionIndex] : nil
    }

    /// Vrai pour la carte au centre. Le carrousel n'estompe pas ses voisines
    /// lui-même : il ne fait que les décaler.
    func isActive(_ action: Action) -> Bool {
        selectedAction?.id == action.id
    }

    /// Le montant se saisit au clavier décimal, qui pose une virgule en
    /// français et un point ailleurs. Les deux sont acceptés.
    var perShareValue: Double? {
        Double(perShare.replacingOccurrences(of: ",", with: "."))
    }

    /// Ce que le serveur figera sur la ligne : la quantité détenue à cet
    /// instant, multipliée par le montant par action. Le montrer avant l'envoi
    /// évite la surprise d'un total qui ne se recalculera jamais.
    var previewLabel: String? {
        guard let action = selectedAction, let perShare = perShareValue, perShare > 0 else {
            return nil
        }
        let total = Double(action.quantity) * perShare
        // Même règle que le trigger : 10 points par euro, plancher à 1.
        let energy = max(1, (total * 10).rounded())
        let totalText = total.formatted(.number.precision(.fractionLength(2)))
        let energyText = energy.formatted(.number.precision(.fractionLength(0)))
        return "\(action.quantity) × \(perShare.formatted()) € = \(totalText) €  ·  +\(energyText) énergie"
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
        guard let perShare = perShareValue, perShare > 0 else {
            errorMessage = "Le montant par action doit être supérieur à zéro"
            return false
        }
        guard let token = TokenStore.shared.token else {
            sessionExpired = true
            return false
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await service.addDividend(
                perShare: perShare,
                paymentDate: paymentDate,
                actionId: action.id,
                token: token
            )
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
