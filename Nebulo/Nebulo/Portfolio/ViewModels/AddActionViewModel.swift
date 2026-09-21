//
//  AddActionViewModel.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation
import Combine

@MainActor
final class AddActionViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var ticker: String = ""
    /// Saisie dans la maquette, mais `actions` n'a pas de colonne pour
    /// l'accueillir : la valeur n'est pas envoyée. Voir les écarts ouverts.
    @Published var value: String = ""
    @Published var quantity: Int = 0
    /// Secteur au centre du carrousel. La maquette ouvre sur le premier.
    @Published var sectorIndex: Int = 0

    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil
    /// Vrai quand le jeton n'est plus accepté : l'écran demande alors une
    /// déconnexion plutôt que d'afficher une erreur insoluble.
    @Published var sessionExpired: Bool = false

    private let service: PortfolioServiceProtocol

    // La valeur par défaut est construite dans le corps : évaluée comme
    // argument par défaut, elle le serait hors de l'acteur principal.
    init(service: PortfolioServiceProtocol? = nil) {
        self.service = service ?? PortfolioService()
    }

    var sectors: [Sector] { SectorCatalog.all }

    /// Vrai pour la carte au centre. Le carrousel n'estompe pas ses voisines
    /// lui-même : il ne fait que les décaler.
    func isActive(_ sector: Sector) -> Bool {
        guard sectors.indices.contains(sectorIndex) else { return false }
        return sectors[sectorIndex].id == sector.id
    }

    /// Le compteur ne descend pas sous zéro : détenir un nombre négatif
    /// d'actions n'a pas de sens, et la colonne est un entier non signé.
    func decrement() {
        quantity = max(0, quantity - 1)
    }

    func increment() {
        quantity += 1
    }

    /// Renvoie vrai quand la création a abouti, pour que l'écran sache
    /// se refermer.
    func save() async -> Bool {
        let name = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let ticker = self.ticker.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else {
            errorMessage = "Le nom ne peut pas être vide"
            return false
        }
        guard !ticker.isEmpty else {
            errorMessage = "Le ticker ne peut pas être vide"
            return false
        }
        guard quantity > 0 else {
            errorMessage = "Indique combien d'actions tu détiens"
            return false
        }
        guard sectors.indices.contains(sectorIndex) else {
            errorMessage = "Choisis un secteur"
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
            _ = try await service.addAction(
                name: name,
                // Le ticker est une convention de place : AAPL, pas aapl.
                ticker: ticker.uppercased(),
                secteur: sectors[sectorIndex].name,
                quantity: quantity,
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
