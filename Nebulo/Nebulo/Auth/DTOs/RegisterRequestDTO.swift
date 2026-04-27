//
//  RegisterRequestDTO.swift
//  Nebulo
//
//  Created by apprenant152 on 27/04/2026.
//

import Foundation

struct RegisterRequestDTO: Encodable {
    let firstname: String
    let lastname: String
    let email: String
    let password: String
    let dateOfBirth: Date
}
