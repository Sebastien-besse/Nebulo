//
//  ProfileService.swift
//  Nebulo
//
//  Created by apprenant152 on 14/09/2026.
//

import Foundation

protocol ProfileServiceProtocol {
    func loadProfile(token: String) async throws -> (user: User, planets: [Planet], grade: UserGrade)
    func updateProfile(_ user: User, password: String?, token: String) async throws -> User
}

final class ProfileService: ProfileServiceProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol = ProfileRepository()) {
        self.repository = repository
    }

    func loadProfile(token: String) async throws -> (user: User, planets: [Planet], grade: UserGrade) {
        // Les trois appels sont indépendants : les lancer en parallèle évite
        // d'additionner trois allers-retours réseau à l'ouverture de l'écran.
        async let userDTO = repository.me(token: token)
        async let planetDTOs = repository.planets(token: token)
        async let gradeDTO = repository.grade(token: token)

        let user = UserMapper.toDomain(try await userDTO)
        let planets = try await planetDTOs.map(PlanetMapper.toDomain)
        let grade = GradeMapper.toDomain(try await gradeDTO)
        return (user, planets, grade)
    }

    func updateProfile(_ user: User, password: String?, token: String) async throws -> User {
        let dto = UpdateProfileRequestDTO(
            firstname: user.firstname,
            lastname: user.lastname,
            email: user.email,
            dateOfBirth: user.dateOfBirth,
            password: password
        )
        return UserMapper.toDomain(try await repository.update(dto, token: token))
    }
}
