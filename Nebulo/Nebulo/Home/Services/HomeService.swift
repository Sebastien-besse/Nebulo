//
//  HomeService.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

protocol HomeServiceProtocol {
    func loadDashboard(token: String) async throws
        -> (summary: DividendSummary, challenge: Challenge?, planets: [Planet], grade: UserGrade)
}

final class HomeService: HomeServiceProtocol {
    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol = HomeRepository()) {
        self.repository = repository
    }

    /// Le challenge d'abord, le reste ensuite, en parallèle.
    ///
    /// Lire le challenge courant n'est pas anodin : le serveur recalcule la
    /// progression, crédite l'énergie si l'objectif est atteint et tire le
    /// suivant. Cette énergie peut débloquer une planète, et le challenge
    /// validé rapporte de l'XP. Lus en même temps que lui, l'énergie, les
    /// planètes et le grade arrivaient d'un instant trop tôt : la jauge restait
    /// en retard, et la planète ou le grade gagnés grâce au challenge n'étaient
    /// fêtés qu'au chargement suivant, loin de la célébration du challenge.
    ///
    /// Un aller-retour de plus, pour un accueil qui dit enfin la vérité.
    func loadDashboard(token: String) async throws
        -> (summary: DividendSummary, challenge: Challenge?, planets: [Planet], grade: UserGrade) {
        let challenge = try await repository.currentChallenge(token: token).map(ChallengeMapper.toDomain)

        async let summaryDTO = repository.summary(token: token)
        async let planetDTOs = repository.planets(token: token)
        async let gradeDTO = repository.grade(token: token)

        let summary = DividendSummaryMapper.toDomain(try await summaryDTO)
        let planets = try await planetDTOs.map(PlanetMapper.toDomain)
        let grade = GradeMapper.toDomain(try await gradeDTO)
        return (summary, challenge, planets, grade)
    }
}
