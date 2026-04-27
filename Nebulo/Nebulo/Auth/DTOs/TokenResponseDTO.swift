//
//  TokenResponseDTO.swift
//  Nebulo
//
//  Created by apprenant152 on 27/04/2026.
//

import Foundation

struct TokenResponseDTO: Decodable {
    let token: String
    let user: UserResponseDTO
}

struct UserResponseDTO: Decodable {
    let id: UUID
    let firstname: String
    let lastname: String
    let email: String
    let energy: Int
    let grade: String
    let dateOfBirth: Date
}
