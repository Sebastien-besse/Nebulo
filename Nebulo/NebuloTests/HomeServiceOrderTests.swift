//
//  HomeServiceOrderTests.swift
//  NebuloTests
//
//  Created by apprenant152 on 29/09/2026.
//

import Foundation
import Testing
@testable import Nebulo

/// Le fil des appels, dans l'ordre où ils ont eu lieu.
private actor Journal {
    private(set) var entries: [String] = []
    func note(_ entry: String) { entries.append(entry) }
}

/// Un dépôt d'accueil sans réseau, qui inscrit chaque appel au journal. Le
/// challenge prend son temps : si les autres lectures partaient en même temps
/// que lui, elles commenceraient avant qu'il ait fini.
private final class RecordingHomeRepository: HomeRepositoryProtocol, @unchecked Sendable {
    let journal = Journal()

    func currentChallenge(token: String) async throws -> UserChallengeResponseDTO? {
        await journal.note("challenge début")
        try await Task.sleep(for: .milliseconds(100))
        await journal.note("challenge fin")
        return nil
    }

    func summary(token: String) async throws -> DividendSummaryResponseDTO {
        await journal.note("summary")
        return DividendSummaryResponseDTO(
            totalAllTime: 0, totalThisMonth: 0, totalThisYear: 0, count: 0, energy: 0
        )
    }

    func planets(token: String) async throws -> [PlanetResponseDTO] {
        await journal.note("planets")
        return []
    }

    func grade(token: String) async throws -> UserGradeResponseDTO {
        await journal.note("grade")
        return UserGradeResponseDTO(xp: 0, current: nil, next: nil, progressPercent: 0)
    }
}

@Suite("Ordre des lectures de l'accueil")
struct HomeServiceOrderTests {

    /// Lire le challenge peut le valider, et donc créditer de l'énergie,
    /// débloquer une planète et faire gagner de l'XP. Le reste ne se lit
    /// qu'ensuite, pour refléter ce que cette validation vient de changer.
    @Test("Énergie, planètes et grade se lisent après le challenge")
    func challengeFirst() async throws {
        let repository = RecordingHomeRepository()
        _ = try await HomeService(repository: repository).loadDashboard(token: "jeton")

        let entries = await repository.journal.entries
        let challengeEnd = try #require(entries.firstIndex(of: "challenge fin"))
        for read in ["summary", "planets", "grade"] {
            let index = try #require(entries.firstIndex(of: read))
            #expect(index > challengeEnd, "\(read) lu avant la fin du challenge : \(entries)")
        }
    }
}
