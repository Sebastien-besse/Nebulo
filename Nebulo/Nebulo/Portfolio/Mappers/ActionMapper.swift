//
//  ActionMapper.swift
//  Nebulo
//
//  Created by apprenant152 on 18/09/2026.
//

import Foundation

enum ActionMapper {
    /// Le cumul des dividendes n'appartient pas au DTO de l'action : il est
    /// calculé à partir d'une seconde réponse et injecté ici, pour que le
    /// modèle de domaine soit complet dès sa construction.
    static func toDomain(_ dto: ActionResponseDTO, dividendsTotal: Double) -> Action {
        Action(
            id: dto.id,
            name: dto.name,
            ticker: dto.ticker,
            secteur: dto.secteur,
            quantity: dto.quantity,
            dividendsTotal: dividendsTotal
        )
    }
}
