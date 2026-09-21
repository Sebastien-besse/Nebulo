//
//  CompanyResponseDTO.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

/// Ce que renvoie `GET /companies/:companyID`.
struct CompanyResponseDTO: Decodable {
    let id: UUID
    let name: String
    let secteur: String
    let description: String
}
