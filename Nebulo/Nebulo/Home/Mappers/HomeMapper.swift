//
//  HomeMapper.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

enum DividendSummaryMapper {
    static func toDomain(_ dto: DividendSummaryResponseDTO) -> DividendSummary {
        DividendSummary(
            totalAllTime: dto.totalAllTime,
            totalThisMonth: dto.totalThisMonth,
            totalThisYear: dto.totalThisYear,
            count: dto.count,
            energy: dto.energy
        )
    }
}

enum ChallengeMapper {
    /// La fiche et l'avancement arrivent imbriqués ; le domaine les met à plat,
    /// l'écran n'ayant jamais besoin de l'un sans l'autre.
    static func toDomain(_ dto: UserChallengeResponseDTO) -> Challenge {
        Challenge(
            id: dto.challenge.id,
            description: dto.challenge.description,
            type: dto.challenge.type,
            objectif: dto.challenge.objectif,
            energyReward: dto.challenge.energyReward,
            assignedAt: dto.assignedAt,
            progress: dto.progress,
            progressPercent: dto.progressPercent,
            completed: dto.completed
        )
    }
}
