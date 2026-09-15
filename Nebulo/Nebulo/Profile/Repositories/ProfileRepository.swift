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
    func update(_ dto: UpdateProfileRequestDTO, token: String) async throws -> UserResponseDTO
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

    func update(_ dto: UpdateProfileRequestDTO, token: String) async throws -> UserResponseDTO {
        try await apiService.put(endpoint: "/users/me", body: dto, token: token)
    }
}
