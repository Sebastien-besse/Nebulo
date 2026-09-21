//
//  ForumRepository.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

protocol ForumRepositoryProtocol {
    func me(token: String) async throws -> UserResponseDTO
    func posts(token: String) async throws -> [PostResponseDTO]
    func vote(_ value: VoteType, postId: UUID, token: String) async throws -> PostResponseDTO
    func removeVote(postId: UUID, token: String) async throws -> PostResponseDTO
    func companies(token: String) async throws -> [CompanyResponseDTO]
    func createPost(_ dto: CreatePostRequestDTO, token: String) async throws -> PostResponseDTO
}

final class ForumRepository: ForumRepositoryProtocol {
    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func me(token: String) async throws -> UserResponseDTO {
        try await apiService.get(endpoint: "/users/me", token: token)
    }

    func posts(token: String) async throws -> [PostResponseDTO] {
        try await apiService.get(endpoint: "/posts", token: token)
    }

    /// Les deux routes de vote répondent avec le post recompté : la liste se
    /// met à jour sans avoir à la recharger entière.
    func vote(_ value: VoteType, postId: UUID, token: String) async throws -> PostResponseDTO {
        try await apiService.put(
            endpoint: "/posts/\(postId.uuidString)/vote",
            body: VoteRequestDTO(value: value),
            token: token
        )
    }

    func removeVote(postId: UUID, token: String) async throws -> PostResponseDTO {
        try await apiService.delete(endpoint: "/posts/\(postId.uuidString)/vote", token: token)
    }

    /// Référentiel en lecture seule, trié par nom côté serveur.
    func companies(token: String) async throws -> [CompanyResponseDTO] {
        try await apiService.get(endpoint: "/companies", token: token)
    }

    func createPost(_ dto: CreatePostRequestDTO, token: String) async throws -> PostResponseDTO {
        try await apiService.post(endpoint: "/posts", body: dto, token: token)
    }
}
