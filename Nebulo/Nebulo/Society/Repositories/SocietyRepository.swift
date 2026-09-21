//
//  SocietyRepository.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

protocol SocietyRepositoryProtocol {
    func company(id: UUID, token: String) async throws -> CompanyResponseDTO
    func posts(companyId: UUID, token: String) async throws -> [PostResponseDTO]
}

final class SocietyRepository: SocietyRepositoryProtocol {
    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func company(id: UUID, token: String) async throws -> CompanyResponseDTO {
        try await apiService.get(endpoint: "/companies/\(id.uuidString)", token: token)
    }

    func posts(companyId: UUID, token: String) async throws -> [PostResponseDTO] {
        try await apiService.get(endpoint: "/companies/\(companyId.uuidString)/posts", token: token)
    }
}
