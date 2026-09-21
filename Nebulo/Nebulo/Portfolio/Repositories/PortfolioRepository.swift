//
//  PortfolioRepository.swift
//  Nebulo
//
//  Created by apprenant152 on 18/09/2026.
//

import Foundation

protocol PortfolioRepositoryProtocol {
    func me(token: String) async throws -> UserResponseDTO
    func actions(userId: UUID, token: String) async throws -> [ActionResponseDTO]
    func dividends(token: String) async throws -> [DividendResponseDTO]
    func create(_ dto: CreateActionRequestDTO, token: String) async throws -> ActionResponseDTO
    func createDividend(_ dto: CreateDividendRequestDTO, token: String) async throws -> DividendResponseDTO
}

final class PortfolioRepository: PortfolioRepositoryProtocol {
    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func me(token: String) async throws -> UserResponseDTO {
        try await apiService.get(endpoint: "/users/me", token: token)
    }

    /// Seule route du projet à porter encore un identifiant d'utilisateur dans
    /// l'URL. Il faut donc le connaître avant d'appeler — d'où le `me()`.
    func actions(userId: UUID, token: String) async throws -> [ActionResponseDTO] {
        try await apiService.get(endpoint: "/users/\(userId.uuidString)/actions", token: token)
    }

    func dividends(token: String) async throws -> [DividendResponseDTO] {
        try await apiService.get(endpoint: "/dividends", token: token)
    }

    func create(_ dto: CreateActionRequestDTO, token: String) async throws -> ActionResponseDTO {
        try await apiService.post(endpoint: "/actions", body: dto, token: token)
    }

    func createDividend(_ dto: CreateDividendRequestDTO, token: String) async throws -> DividendResponseDTO {
        try await apiService.post(endpoint: "/dividends", body: dto, token: token)
    }
}
