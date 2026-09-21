//
//  SocietyService.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

protocol SocietyServiceProtocol {
    func loadSociety(companyId: UUID, token: String) async throws -> (company: Company, posts: [Post])
}

final class SocietyService: SocietyServiceProtocol {
    private let repository: SocietyRepositoryProtocol

    init(repository: SocietyRepositoryProtocol = SocietyRepository()) {
        self.repository = repository
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
}
