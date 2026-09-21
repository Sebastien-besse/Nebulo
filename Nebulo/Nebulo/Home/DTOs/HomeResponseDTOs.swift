//
//  HomeResponseDTOs.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

/// Ce que renvoie `GET /dividends/summary`. C'est la source du tableau de bord.
struct DividendSummaryResponseDTO: Decodable {
    let totalAllTime: Double
    let totalThisMonth: Double
    let totalThisYear: Double
    let count: Int
    /// Énergie accumulée, entretenue par le trigger `after_insert_dividend`.
    let energy: Int
}

/// La fiche du challenge, telle qu'elle vit dans le pool.
struct ChallengeResponseDTO: Decodable {
    let id: UUID
    let description: String
    let type: ChallengeType
    let objectif: Int
    let energyReward: Int
}

/// Ce que renvoie `GET /challenges/current` : la fiche, plus l'avancement du
/// porteur du jeton. La route répond **204** quand le pool est épuisé.
struct UserChallengeResponseDTO: Decodable {
    let challenge: ChallengeResponseDTO
    let assignedAt: Date
    let progress: Double
    let progressPercent: Double
    let completed: Bool
    let completedAt: Date?
}
