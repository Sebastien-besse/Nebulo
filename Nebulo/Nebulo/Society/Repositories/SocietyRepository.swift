//
//  SocietyRepository.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

protocol SocietyRepositoryProtocol {
    func company(id: UUID, token: String) async throws -> CompanyResponseDTO
    /// Les commentaires d'un post, chronologiques côté serveur.
    func comments(postId: UUID, token: String) async throws -> [PostResponseDTO]
    func createComment(_ dto: CreateResponseRequestDTO, postId: UUID, token: String) async throws -> PostResponseDTO
}

final class SocietyRepository: SocietyRepositoryProtocol {
    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func company(id: UUID, token: String) async throws -> CompanyResponseDTO {
        try await apiService.get(endpoint: "/companies/\(id.uuidString)", token: token)
    }

    func comments(postId: UUID, token: String) async throws -> [PostResponseDTO] {
        try await apiService.get(endpoint: "/posts/\(postId.uuidString)/comments", token: token)
    }

    /// Le corps ne porte que le texte : le post visé est dans l'URL, et la
    /// société se déduit de lui côté serveur.
    func createComment(_ dto: CreateResponseRequestDTO, postId: UUID, token: String) async throws -> PostResponseDTO {
        try await apiService.post(endpoint: "/posts/\(postId.uuidString)/comments", body: dto, token: token)
    }
}
