//
//  CompanyMapper.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

enum CompanyMapper {
    static func toDomain(_ dto: CompanyResponseDTO) -> Company {
        Company(
            id: dto.id,
            name: dto.name,
            secteur: dto.secteur,
            description: dto.description
        )
    }
}
