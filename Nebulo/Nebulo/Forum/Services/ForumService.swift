//
//  ForumService.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

protocol ForumServiceProtocol {
    func loadForum(token: String) async throws -> (viewerId: UUID, posts: [Post])
    func toggleVote(_ value: VoteType, on post: Post, token: String) async throws -> Post
    func loadCompanies(token: String) async throws -> [Company]
    func createPost(content: String, companyId: UUID?, token: String) async throws -> Post
}

final class ForumService: ForumServiceProtocol {
    private let repository: ForumRepositoryProtocol

    init(repository: ForumRepositoryProtocol = ForumRepository()) {
        self.repository = repository
    }

    /// Le fil et l'identité du lecteur partent ensemble : l'API refuse qu'on
    /// vote sur son propre post, et l'écran doit le savoir pour éteindre les
    /// boutons plutôt que d'aller chercher un 403.
    func loadForum(token: String) async throws -> (viewerId: UUID, posts: [Post]) {
        async let userDTO = repository.me(token: token)
        async let postDTOs = repository.posts(token: token)

        let viewerId = try await userDTO.id
        let posts = try await postDTOs.map(PostMapper.toDomain)
        return (viewerId, posts)
    }

    /// Voter deux fois la même valeur retire le vote : c'est le seul moyen de
    /// revenir en arrière, la maquette n'offrant pas de troisième bouton.
    func toggleVote(_ value: VoteType, on post: Post, token: String) async throws -> Post {
        let dto = post.myVote == value
            ? try await repository.removeVote(postId: post.id, token: token)
            : try await repository.vote(value, postId: post.id, token: token)
        return PostMapper.toDomain(dto)
    }

    func loadCompanies(token: String) async throws -> [Company] {
        try await repository.companies(token: token).map(CompanyMapper.toDomain)
    }

    func createPost(content: String, companyId: UUID?, token: String) async throws -> Post {
        let dto = CreatePostRequestDTO(content: content, companyId: companyId)
        return PostMapper.toDomain(try await repository.createPost(dto, token: token))
    }
}
