//
//  PlanetMapper.swift
//  Nebulo
//
//  Created by apprenant152 on 14/09/2026.
//

import Foundation

enum PlanetMapper {
    static func toDomain(_ dto: PlanetResponseDTO) -> Planet {
        Planet(
            id: dto.id,
            image: dto.image,
            name: dto.name,
            nickname: dto.nickname,
            surface: dto.surface,
            temperature: dto.temperature,
            description: dto.description,
            energyThreshold: dto.energyThreshold,
            locked: dto.locked,
            unlockedAt: dto.unlockedAt
        )
    }
}
