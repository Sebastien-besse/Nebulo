//
//  SocietyService.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

protocol SocietyServiceProtocol {
    func loadSociety(companyId: UUID, token: String) async throws -> (company: Company, posts: [Post])
    /// Publie un commentaire sur l'entreprise. C'est un message du forum comme
    /// un autre — la fiche société n'est qu'une autre entrée sur le même fil —,
    /// d'où la délégation au service du forum plutôt qu'un second chemin vers
    /// le même endpoint.
    func createComment(content: String, companyId: UUID, token: String) async throws -> Post
}

final class SocietyService: SocietyServiceProtocol {
    private let repository: SocietyRepositoryProtocol
    private let forum: ForumServiceProtocol

    init(
        repository: SocietyRepositoryProtocol = SocietyRepository(),
        forum: ForumServiceProtocol = ForumService()
    ) {
        self.repository = repository
        self.forum = forum
    }

    func loadSociety(companyId: UUID, token: String) async throws -> (company: Company, posts: [Post]) {
        // La fiche et son fil sont indépendants : les lancer en parallèle évite
        // d'additionner deux allers-retours à l'ouverture de l'écran.
        async let companyDTO = repository.company(id: companyId, token: token)
        async let postDTOs = repository.posts(companyId: companyId, token: token)

        let company = CompanyMapper.toDomain(try await companyDTO)
        let posts = try await postDTOs.map(PostMapper.toDomain)
        return (company, posts)
    }

    func createComment(content: String, companyId: UUID, token: String) async throws -> Post {
        try await forum.createPost(content: content, companyId: companyId, token: token)
    }
}
