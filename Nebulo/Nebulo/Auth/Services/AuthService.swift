//
//  AuthService.swift
//  Nebulo
//
//  Created by apprenant152 on 27/04/2026.
//

import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> (token: String, user: User)
    func register(firstname: String, lastname: String, email: String, password: String, dateOfBirth: Date) async throws -> (token: String, user: User)
}

final class AuthService: AuthServiceProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository
    }

    func login(email: String, password: String) async throws -> (token: String, user: User) {
        let dto = LoginRequestDTO(email: email, password: password)
        let response = try await repository.login(dto: dto)
        return (response.token, UserMapper.toDomain(response.user))
    }

    func register(
        firstname: String,
        lastname: String,
        email: String,
        password: String,
        dateOfBirth: Date
    ) async throws -> (token: String, user: User) {
        let dto = RegisterRequestDTO(
            firstname: firstname,
            lastname: lastname,
            email: email,
            password: password,
            dateOfBirth: dateOfBirth
        )
        let response = try await repository.register(dto: dto)
        return (response.token, UserMapper.toDomain(response.user))
    }
}
