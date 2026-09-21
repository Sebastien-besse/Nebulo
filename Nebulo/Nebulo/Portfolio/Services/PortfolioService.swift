//
//  PortfolioService.swift
//  Nebulo
//
//  Created by apprenant152 on 18/09/2026.
//

import Foundation

protocol PortfolioServiceProtocol {
    func loadPortfolio(token: String) async throws -> [Action]
    func addAction(name: String, ticker: String, secteur: String, quantity: Int,
                   token: String) async throws -> Action
    func addDividend(perShare: Double, paymentDate: Date, actionId: UUID,
                     token: String) async throws
}

final class PortfolioService: PortfolioServiceProtocol {
    private let repository: PortfolioRepositoryProtocol

    init(repository: PortfolioRepositoryProtocol = PortfolioRepository()) {
        self.repository = repository
    }

    func loadPortfolio(token: String) async throws -> [Action] {
        // Le profil et les dividendes sont indépendants : les lancer ensemble
        // évite d'additionner deux allers-retours. La liste des actions, elle,
        // attend l'identifiant que seul `/users/me` peut donner.
        async let userDTO = repository.me(token: token)
        async let dividendDTOs = repository.dividends(token: token)

        let actionDTOs = try await repository.actions(userId: userDTO.id, token: token)

        // Un seul `GET /dividends` sert tout l'écran : sommer côté client
        // évite un appel par action, et donc un N+1 sur un portefeuille long.
        let totals = try await dividendDTOs.reduce(into: [UUID: Double]()) { totals, dividend in
            totals[dividend.actionId, default: 0] += dividend.total
        }

        return actionDTOs.map { ActionMapper.toDomain($0, dividendsTotal: totals[$0.id] ?? 0) }
    }

    /// Une action vient de naître : elle n'a encore versé aucun dividende,
    /// d'où le cumul à zéro plutôt qu'un second aller-retour pour l'apprendre.
    func addAction(name: String, ticker: String, secteur: String, quantity: Int,
                   token: String) async throws -> Action {
        let dto = CreateActionRequestDTO(
            name: name,
            ticker: ticker,
            secteur: secteur,
            quantity: quantity
        )
        return ActionMapper.toDomain(try await repository.create(dto, token: token),
                                     dividendsTotal: 0)
    }

    /// Rien n'est renvoyé : la ligne créée n'intéresse pas l'appelant, qui
    /// recharge le portefeuille entier. L'insertion déclenche en base le
    /// crédit d'énergie, puis le déblocage des planètes — aucune de ces
    /// conséquences n'est visible dans la réponse.
    func addDividend(perShare: Double, paymentDate: Date, actionId: UUID,
                     token: String) async throws {
        let dto = CreateDividendRequestDTO(
            dividendPerShare: perShare,
            paymentDate: paymentDate,
            actionId: actionId
        )
        _ = try await repository.createDividend(dto, token: token)
    }
}
