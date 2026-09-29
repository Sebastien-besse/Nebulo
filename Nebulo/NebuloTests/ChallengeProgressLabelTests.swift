//
//  ChallengeProgressLabelTests.swift
//  NebuloTests
//
//  Created by apprenant152 on 29/09/2026.
//

import Foundation
import Testing
@testable import Nebulo

/// Un challenge réduit à ce que lit `progressLabel` : son type, son objectif
/// et l'avancement renvoyé par le serveur.
private func challenge(_ type: ChallengeType, objectif: Int, progress: Double) -> Challenge {
    Challenge(
        id: UUID(),
        description: "",
        type: type,
        objectif: objectif,
        energyReward: 0,
        assignedAt: .now,
        progress: progress,
        progressPercent: 0,
        completed: false
    )
}

@Suite("Libellé d'avancement d'un challenge")
struct ChallengeProgressLabelTests {

    @Test("Un montant garde ses deux décimales")
    func amountWithCents() {
        #expect(challenge(.dividendTotal, objectif: 3, progress: 1.2).progressLabel == "1,20 € / 3 €")
    }

    @Test("Un montant rond n'affiche pas de centimes")
    func roundAmount() {
        #expect(challenge(.dividendTotal, objectif: 5, progress: 2).progressLabel == "2 € / 5 €")
        #expect(challenge(.dividendMax, objectif: 2, progress: 0).progressLabel == "0 € / 2 €")
    }

    @Test("Un décompte s'écrit sans unité")
    func count() {
        #expect(challenge(.voteCount, objectif: 5, progress: 3).progressLabel == "3 / 5")
        #expect(challenge(.dividendStocks, objectif: 2, progress: 1).progressLabel == "1 / 2")
    }
}
