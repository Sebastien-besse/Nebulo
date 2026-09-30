//
//  SocietyService.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

protocol SocietyServiceProtocol {
    /// La fiche de l'entreprise et les commentaires du post ouvert.
    func loadSociety(companyId: UUID, postId: UUID, token: String) async throws -> (company: Company, comments: [Post])
    /// Commente le post : une nouvelle carte du carrousel, jamais une réponse
    /// sous un commentaire ni un nouveau post du forum.
    func createComment(content: String, postId: UUID, token: String) async throws -> Post
}

final class SocietyService: SocietyServiceProtocol {
    private let repository: SocietyRepositoryProtocol

    init(repository: SocietyRepositoryProtocol = SocietyRepository()) {
        self.repository = repository
    }

    func loadSociety(companyId: UUID, postId: UUID, token: String) async throws -> (company: Company, comments: [Post]) {
        // La fiche et les commentaires sont indépendants : les lancer en
        // parallèle évite d'additionner deux allers-retours à l'ouverture.
        async let companyDTO = repository.company(id: companyId, token: token)
        async let commentDTOs = repository.comments(postId: postId, token: token)

        let company = CompanyMapper.toDomain(try await companyDTO)
        let comments = try await commentDTOs.map(PostMapper.toDomain)
        return (company, comments)
    }

    func createComment(content: String, postId: UUID, token: String) async throws -> Post {
        let dto = CreateResponseRequestDTO(content: content)
        return PostMapper.toDomain(try await repository.createComment(dto, postId: postId, token: token))
    }
}
