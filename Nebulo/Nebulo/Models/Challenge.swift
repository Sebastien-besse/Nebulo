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
    /// Plus gros dividende encaissé depuis le tirage, en euros.
    case dividendMax = "DIVIDEND_MAX"
    /// Nombre d'actions différentes ayant versé un dividende depuis le tirage.
    case dividendStocks = "DIVIDEND_STOCKS"
    /// Nombre de posts publiés sur le forum depuis le tirage, commentaires de
    /// société exclus.
    case postCount = "POST_COUNT"
    /// Nombre de sociétés différentes commentées depuis le tirage.
    case companyCommentCount = "COMPANY_COMMENT_COUNT"
    /// Nombre de réponses écrites depuis le tirage.
    case responseCount = "RESPONSE_COUNT"
    /// Nombre de posts votés depuis le tirage.
    case voteCount = "VOTE_COUNT"
}

/// Le challenge tiré au sort pour l'utilisateur, et son avancement.
///
/// Les challenges sont tirés dans un pool, jamais deux fois le même. Le
/// suivant tombe dès que le précédent est validé, sans calendrier.
struct Challenge: Equatable {
    let id: UUID
    let description: String
    let type: ChallengeType
    let objectif: Int
    let energyReward: Int
    /// XP rapportée à la validation, selon la difficulté.
    var xpReward: Int = 0
    let assignedAt: Date
    /// Valeur atteinte depuis le tirage, dans l'unité du type.
    let progress: Double
    /// Avancement de 0 à 100, déjà plafonné par le serveur.
    let progressPercent: Double
    let completed: Bool

    /// L'avancement dans l'unité du challenge : « 1,20 € / 3 € » pour un
    /// montant, « 1 / 3 » pour un décompte.
    ///
    /// Les centimes n'apparaissent que s'il y en a : un objectif de 3 € reste
    /// « 3 € », pas « 3,00 € ».
    var progressLabel: String {
        switch type {
        case .dividendTotal, .dividendMax:
            // Deux décimales ou aucune : « 1,2 € » ne s'écrit pas.
            let decimals = progress.rounded() == progress ? 0 : 2
            let amount = progress.formatted(.number.precision(.fractionLength(decimals)))
            return "\(amount) € / \(objectif) €"
        case .dividendCount, .dividendStocks, .postCount, .companyCommentCount,
             .responseCount, .voteCount:
            return "\(Int(progress)) / \(objectif)"
        }
    }
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
    energyReward: 8,
    xpReward: 80,
    assignedAt: .now,
    progress: 1.2,
    progressPercent: 60,
    completed: false
)
