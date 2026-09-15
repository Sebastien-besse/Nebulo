//
//  ProfileService.swift
//  Nebulo
//
//  Created by apprenant152 on 14/09/2026.
//

import Foundation

protocol ProfileServiceProtocol {
    func loadProfile(token: String) async throws -> (user: User, planets: [Planet])
    func updateProfile(_ user: User, password: String?, token: String) async throws -> User
}

final class ProfileService: ProfileServiceProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol = ProfileRepository()) {
        self.repository = repository
    }

    func loadProfile(token: String) async throws -> (user: User, planets: [Planet]) {
        // Les deux appels sont indépendants : les lancer en parallèle évite
        // d'additionner deux allers-retours réseau à l'ouverture de l'écran.
        async let userDTO = repository.me(token: token)
        async let planetDTOs = repository.planets(token: token)

        let user = UserMapper.toDomain(try await userDTO)
        let planets = try await planetDTOs.map(PlanetMapper.toDomain)
        return (user, planets)
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
