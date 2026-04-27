//
//  AuthRepository.swift
//  Nebulo
//
//  Created by apprenant152 on 27/04/2026.
//

import Foundation

protocol AuthRepositoryProtocol {
    func login(dto: LoginRequestDTO) async throws -> TokenResponseDTO
    func register(dto: RegisterRequestDTO) async throws -> TokenResponseDTO
}

final class AuthRepository: AuthRepositoryProtocol {
    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func login(dto: LoginRequestDTO) async throws -> TokenResponseDTO {
        try await apiService.post(endpoint: "/auth/login", body: dto)
    }

    func register(dto: RegisterRequestDTO) async throws -> TokenResponseDTO {
        try await apiService.post(endpoint: "/auth/register", body: dto)
    }
}
