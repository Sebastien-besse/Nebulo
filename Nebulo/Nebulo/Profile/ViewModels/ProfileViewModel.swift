//
//  ProfileViewModel.swift
//  Nebulo
//
//  Created by apprenant152 on 14/09/2026.
//

import Foundation
import Combine

/// Les champs du profil que l'utilisateur peut modifier.
enum ProfileField: String, Identifiable {
    case firstname, lastname, email, password

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstname: return "Prénom"
        case .lastname:  return "Nom"
        case .email:     return "Email"
        case .password:  return "Mot de passe"
        }
    }

    /// Le mot de passe ne s'affiche jamais et se saisit masqué.
    var isSecure: Bool { self == .password }
}

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var planets: [Planet] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    /// Vrai une fois que le serveur a répondu. Sert à distinguer « pas encore
    /// de planète » d'un chargement qui a échoué : les deux laissent la liste
    /// vide, mais ne se disent pas de la même façon.
    @Published var hasLoaded: Bool = false
    /// Vrai dès qu'un chargement a été tenté, abouti ou non. Les previews le
    /// mettent à vrai pour que l'écran n'aille jamais toucher le trousseau ni
    /// le réseau, dont elles ne disposent pas.
    @Published var hasAttemptedLoad: Bool = false
    /// Vrai quand le jeton n'est plus accepté : l'écran demande alors une
    /// déconnexion plutôt que d'afficher une erreur que l'utilisateur ne peut
    /// pas résoudre.
    @Published var sessionExpired: Bool = false

    /// Champ en cours de modification, et sa valeur de travail. Tant que
    /// l'enregistrement n'a pas abouti, le profil affiché reste inchangé.
    @Published var editingField: ProfileField? = nil
    @Published var draft: String = ""
    @Published var isSaving: Bool = false

    private let service: ProfileServiceProtocol

    // La valeur par défaut est construite dans le corps : évaluée comme
    // argument par défaut, elle le serait hors de l'acteur principal.
    init(service: ProfileServiceProtocol? = nil) {
        self.service = service ?? ProfileService()
    }

    /// Les huit planètes, de la plus proche à la plus lointaine. Celles qui ne
    /// sont pas atteintes restent visibles, verrouillées : elles montrent ce
    /// qu'il reste à parcourir.
    var sortedPlanets: [Planet] {
        planets.sorted { $0.energyThreshold < $1.energyThreshold }
    }

    /// Le grade courant, retrouvé par son nom parmi les huit badges.
    /// Renvoie nil tant que le serveur n'attribue pas un grade du catalogue.
    var currentGrade: Badge? {
        guard let grade = user?.grade.lowercased() else { return nil }
        return GradeCatalog.all.first { $0.name.lowercased() == grade }
    }

    /// Ouvre la modification d'un champ, pré-remplie avec sa valeur actuelle.
    func startEditing(_ field: ProfileField) {
        guard let user else { return }
        editingField = field
        errorMessage = nil
        switch field {
        case .firstname: draft = user.firstname
        case .lastname:  draft = user.lastname
        case .email:     draft = user.email
        // Le mot de passe n'est jamais connu du client : on repart d'un champ
        // vide plutôt que d'un masque qui laisserait croire le contraire.
        case .password:  draft = ""
        }
    }

    func cancelEditing() {
        editingField = nil
        draft = ""
    }

    /// Envoie le profil complet avec le champ modifié, et n'applique le
    /// changement localement qu'une fois le serveur d'accord.
    func saveEditing() async {
        guard let field = editingField, let user else { return }
        // Un mot de passe peut légitimement contenir des espaces en bordure.
        let value = field == .password
            ? draft
            : draft.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !value.isEmpty else {
            errorMessage = "\(field.title) ne peut pas être vide"
            return
        }
        if field == .email, !(value.contains("@") && value.contains(".")) {
            errorMessage = "Adresse email invalide"
            return
        }
        if field == .password, value.count < 8 {
            errorMessage = "Le mot de passe doit contenir au moins 8 caractères"
            return
        }

        guard let token = TokenStore.shared.token else {
            sessionExpired = true
            return
        }

        let updated = User(
            id: user.id,
            firstname: field == .firstname ? value : user.firstname,
            lastname:  field == .lastname  ? value : user.lastname,
            email:     field == .email     ? value : user.email,
            energy: user.energy,
            grade: user.grade,
            dateOfBirth: user.dateOfBirth
        )

        isSaving = true
        errorMessage = nil
        do {
            self.user = try await service.updateProfile(
                updated,
                password: field == .password ? value : nil,
                token: token
            )
            editingField = nil
            draft = ""
        } catch APIError.httpError(let statusCode, _) where statusCode == 401 {
            sessionExpired = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isSaving = false
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
            let (user, planets) = try await service.loadProfile(token: token)
            self.user = user
            self.planets = planets
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
