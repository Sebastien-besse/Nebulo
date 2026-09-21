//
//  HomeService.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

protocol HomeServiceProtocol {
    func loadDashboard(token: String) async throws
        -> (summary: DividendSummary, challenge: Challenge?, planets: [Planet])
}

final class HomeService: HomeServiceProtocol {
    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol = HomeRepository()) {
        self.repository = repository
    }

    /// Les trois appels sont indépendants : les lancer en parallèle évite
    /// d'additionner trois allers-retours à l'ouverture de l'accueil.
    ///
    /// Lire le challenge courant n'est pas anodin : le serveur recalcule la
    /// progression, crédite l'énergie si l'objectif est atteint et tire le
    /// suivant. Le montant lu en parallèle peut donc être d'un instant
    /// antérieur à l'énergie que ce même appel vient de créditer.
    func loadDashboard(token: String) async throws
        -> (summary: DividendSummary, challenge: Challenge?, planets: [Planet]) {
        async let summaryDTO = repository.summary(token: token)
        async let challengeDTO = repository.currentChallenge(token: token)
        async let planetDTOs = repository.planets(token: token)

        let summary = DividendSummaryMapper.toDomain(try await summaryDTO)
        let challenge = try await challengeDTO.map(ChallengeMapper.toDomain)
        let planets = try await planetDTOs.map(PlanetMapper.toDomain)
        return (summary, challenge, planets)
    }
}
