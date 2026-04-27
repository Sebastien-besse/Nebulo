//
//  UserMapper.swift
//  Nebulo
//
//  Created by apprenant152 on 27/04/2026.
//

import Foundation

enum UserMapper {
    static func toDomain(_ dto: UserResponseDTO) -> User {
        User(
            id: dto.id,
            firstname: dto.firstname,
            lastname: dto.lastname,
            email: dto.email,
            energy: dto.energy,
            grade: dto.grade,
            dateOfBirth: dto.dateOfBirth
        )
    }
}
