//
//  ProfileRepository.swift
//  Nebulo
//
//  Created by apprenant152 on 14/09/2026.
//

import Foundation

protocol ProfileRepositoryProtocol {
    func me(token: String) async throws -> UserResponseDTO
    func planets(token: String) async throws -> [PlanetResponseDTO]
    func grade(token: String) async throws -> UserGradeResponseDTO
    func update(_ dto: UpdateProfileRequestDTO, token: String) async throws -> UserResponseDTO
    func delete(password: String, token: String) async throws
}

final class ProfileRepository: ProfileRepositoryProtocol {
    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func me(token: String) async throws -> UserResponseDTO {
        try await apiService.get(endpoint: "/users/me", token: token)
    }

    func planets(token: String) async throws -> [PlanetResponseDTO] {
        try await apiService.get(endpoint: "/planets", token: token)
    }

    /// L'XP et le grade sont recalculés par le serveur à chaque lecture : rien
    /// n'est mis en cache ici, sinon la barre retarderait d'un chargement.
    func grade(token: String) async throws -> UserGradeResponseDTO {
        try await apiService.get(endpoint: "/grades/me", token: token)
    }

    func update(_ dto: UpdateProfileRequestDTO, token: String) async throws -> UserResponseDTO {
        try await apiService.put(endpoint: "/users/me", body: dto, token: token)
    }

    /// Le serveur répond `204 No Content` : il n'y a rien à décoder. Les
    /// actions, dividendes, posts et votes du compte partent avec lui, par
    /// cascade en base. Un mot de passe faux répond `403`.
    func delete(password: String, token: String) async throws {
        try await apiService.deleteNoContent(
            endpoint: "/users/me",
            body: DeleteAccountRequestDTO(password: password),
            token: token
        )
    }
}
