//
//  AddPostViewModel.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation
import Combine

@MainActor
final class AddPostViewModel: ObservableObject {
    /// Saisi dans la maquette, mais `posts` n'a pas de colonne pour
    /// l'accueillir : le titre n'est pas envoyé. Voir les écarts ouverts.
    @Published var name: String = ""
    @Published var content: String = ""
    /// Le référentiel arrive du serveur, trié par nom.
    @Published var companies: [Company] = []
    /// Entreprise au centre du carrousel.
    @Published var companyIndex: Int = 0

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

    private let service: ForumServiceProtocol

    // La valeur par défaut est construite dans le corps : évaluée comme
    // argument par défaut, elle le serait hors de l'acteur principal.
    init(service: ForumServiceProtocol? = nil) {
        self.service = service ?? ForumService()
    }

    /// Vrai pour la carte au centre. Le carrousel n'estompe pas ses voisines
    /// lui-même : il ne fait que les décaler.
    func isActive(_ company: Company) -> Bool {
        guard companies.indices.contains(companyIndex) else { return false }
        return companies[companyIndex].id == company.id
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
            companies = try await service.loadCompanies(token: token)
        } catch APIError.httpError(let statusCode, _) where statusCode == 401 {
            sessionExpired = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isLoading = false
    }

    /// Renvoie vrai quand la publication a abouti, pour que l'écran sache
    /// se refermer.
    func save() async -> Bool {
        let content = self.content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !content.isEmpty else {
            errorMessage = "Le message ne peut pas être vide"
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
            // Le référentiel peut être vide : le message part alors sans
            // entreprise, ce que l'API accepte.
            let companyId = companies.indices.contains(companyIndex)
                ? companies[companyIndex].id
                : nil
            _ = try await service.createPost(content: content, companyId: companyId, token: token)
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
