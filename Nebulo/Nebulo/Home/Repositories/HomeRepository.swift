//
//  HomeRepository.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

protocol HomeRepositoryProtocol {
    func summary(token: String) async throws -> DividendSummaryResponseDTO
    func currentChallenge(token: String) async throws -> UserChallengeResponseDTO?
    func planets(token: String) async throws -> [PlanetResponseDTO]
}

final class HomeRepository: HomeRepositoryProtocol {
    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func summary(token: String) async throws -> DividendSummaryResponseDTO {
        try await apiService.get(endpoint: "/dividends/summary", token: token)
    }

    /// Nil quand le pool est épuisé : la route répond alors 204, sans corps.
    func currentChallenge(token: String) async throws -> UserChallengeResponseDTO? {
        try await apiService.getOptional(endpoint: "/challenges/current", token: token)
    }

    /// Les huit planètes avec l'état de progression de l'appelant. Le DTO
    /// et le mapper sont ceux du Profil : c'est la même route.
    func planets(token: String) async throws -> [PlanetResponseDTO] {
        try await apiService.get(endpoint: "/planets", token: token)
    }
}
