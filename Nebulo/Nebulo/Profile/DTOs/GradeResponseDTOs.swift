//
//  GradeResponseDTOs.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

/// Une ligne du référentiel des grades.
struct GradeResponseDTO: Decodable {
    let id: UUID
    let name: String
    /// Nom de l'asset iOS, donné par le serveur : le client n'a plus à le déduire.
    let image: String
    let xpThreshold: Int
}

/// Ce que renvoie `GET /grades/me`.
struct UserGradeResponseDTO: Decodable {
    let xp: Int
    let current: GradeResponseDTO?
    let next: GradeResponseDTO?
    let progressPercent: Double
}
