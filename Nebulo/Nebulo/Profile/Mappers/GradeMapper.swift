//
//  GradeMapper.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

enum GradeMapper {
    static func toDomain(_ dto: UserGradeResponseDTO) -> UserGrade {
        UserGrade(
            xp: dto.xp,
            current: dto.current.map { Badge(image: $0.image, name: $0.name) },
            next: dto.next.map { Badge(image: $0.image, name: $0.name) },
            progressPercent: dto.progressPercent,
            nextThreshold: dto.next?.xpThreshold
        )
    }
}
