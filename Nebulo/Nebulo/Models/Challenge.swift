//
//  Challenge.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

/// Ce que mesure un challenge.
enum ChallengeType: String, Codable {
    /// Euros de dividendes encaissés depuis le tirage.
    case dividendTotal = "DIVIDEND_TOTAL"
    /// Nombre de dividendes enregistrés depuis le tirage.
    case dividendCount = "DIVIDEND_COUNT"
}

/// Le challenge tiré au sort pour l'utilisateur, et son avancement.
///
/// Les challenges sont tirés dans un pool, jamais deux fois le même. Le
/// suivant tombe dès que le précédent est validé, sans calendrier.
struct Challenge {
    let id: UUID
    let description: String
    let type: ChallengeType
    let objectif: Int
    let energyReward: Int
    let assignedAt: Date
    /// Valeur atteinte depuis le tirage, dans l'unité du type.
    let progress: Double
    /// Avancement de 0 à 100, déjà plafonné par le serveur.
    let progressPercent: Double
    let completed: Bool
}

/// Synthèse des dividendes, source du montant affiché sur l'accueil.
struct DividendSummary {
    let totalAllTime: Double
    let totalThisMonth: Double
    let totalThisYear: Double
    let count: Int
    let energy: Int
}

/// Données d'exemple pour les previews.
let fakeSummary = DividendSummary(
    totalAllTime: 327.5, totalThisMonth: 36, totalThisYear: 212, count: 9, energy: 3275
)

let fakeChallenge = Challenge(
    id: UUID(),
    description: "Augmente de 2€ tes dividendes",
    type: .dividendTotal,
    objectif: 2,
    energyReward: 300,
    assignedAt: .now,
    progress: 1.2,
    progressPercent: 60,
    completed: false
)
