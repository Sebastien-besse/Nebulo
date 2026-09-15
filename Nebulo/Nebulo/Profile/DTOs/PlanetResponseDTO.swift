//
//  PlanetResponseDTO.swift
//  Nebulo
//
//  Created by apprenant152 on 14/09/2026.
//

import Foundation

/// Ce que renvoie `GET /planets` : la fiche du référentiel et l'état de
/// progression du porteur du jeton, fusionnés.
struct PlanetResponseDTO: Decodable {
    let id: UUID
    let image: String
    let name: String
    let nickname: String
    let surface: Int
    let temperature: Int
    let description: String
    let energyThreshold: Int
    let locked: Bool
    /// Absent tant que la planète n'est pas atteinte : Vapor n'encode pas les
    /// champs optionnels nuls.
    let unlockedAt: Date?
}
