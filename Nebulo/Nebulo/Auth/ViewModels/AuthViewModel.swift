//
//  AuthViewModel.swift
//  Nebulo
//
//  Created by apprenant152 on 27/04/2026.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentUser: User? = nil

    private let service: AuthServiceProtocol

    init(service: AuthServiceProtocol = AuthService()) {
        self.service = service
        self.isAuthenticated = TokenStore.shared.token != nil
    }

    func login(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Veuillez remplir tous les champs"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let (token, user) = try await service.login(email: email, password: password)
            TokenStore.shared.save(token: token)
            currentUser = user
            isAuthenticated = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isLoading = false
    }

    func register(firstname: String, lastname: String, email: String, password: String, dateOfBirth: Date) async {
        guard !firstname.isEmpty, !lastname.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Veuillez remplir tous les champs"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let (token, user) = try await service.register(
                firstname: firstname,
                lastname: lastname,
                email: email,
                password: password,
                dateOfBirth: dateOfBirth
            )
            TokenStore.shared.save(token: token)
            currentUser = user
            isAuthenticated = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isLoading = false
    }

    func logout() {
        TokenStore.shared.clear()
        currentUser = nil
        isAuthenticated = false
    }
}
