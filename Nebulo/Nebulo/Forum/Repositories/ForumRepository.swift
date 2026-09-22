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
    func responses(postId: UUID, token: String) async throws -> [ResponseDTO]
    func createResponse(_ dto: CreateResponseRequestDTO, postId: UUID, token: String) async throws -> ResponseDTO
    func deleteResponse(id: UUID, token: String) async throws
    func deletePost(id: UUID, token: String) async throws
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

    /// Le fil d'un message, chronologique côté serveur.
    func responses(postId: UUID, token: String) async throws -> [ResponseDTO] {
        try await apiService.get(endpoint: "/posts/\(postId.uuidString)/responses", token: token)
    }

    /// La route répond avec la réponse créée : elle rejoint la liste sans
    /// qu'on aille la rechercher.
    func createResponse(_ dto: CreateResponseRequestDTO, postId: UUID, token: String) async throws -> ResponseDTO {
        try await apiService.post(endpoint: "/posts/\(postId.uuidString)/responses", body: dto, token: token)
    }

    /// La route est à la racine, pas sous son post : l'identifiant de la
    /// réponse suffit à la désigner. Elle répond `204`, sans corps.
    func deleteResponse(id: UUID, token: String) async throws {
        try await apiService.deleteNoContent(endpoint: "/responses/\(id.uuidString)", token: token)
    }

    /// Répond `204`, elle aussi. Les réponses du post partent avec lui : la
    /// clé étrangère de `responses` est en CASCADE.
    func deletePost(id: UUID, token: String) async throws {
        try await apiService.deleteNoContent(endpoint: "/posts/\(id.uuidString)", token: token)
    }
}
