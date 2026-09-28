//
//  AddSharesTests.swift
//  NebuloTests
//
//  Created by apprenant152 on 24/09/2026.
//

import Foundation
import Testing
@testable import Nebulo

/// Un service de portefeuille qui rend ce qu'on lui a posé, sans réseau, et
/// retient le dernier renforcement demandé.
private final class FakePortfolioService: PortfolioServiceProtocol, @unchecked Sendable {
    var portfolio: [Action]
    var error: Error?
    private(set) var addedShares: (action: Action, quantity: Int)?

    init(portfolio: [Action], error: Error? = nil) {
        self.portfolio = portfolio
        self.error = error
    }

    func loadPortfolio(token: String) async throws -> [Action] {
        if let error { throw error }
        return portfolio
    }

    func addAction(name: String, ticker: String, secteur: String, quantity: Int,
                   token: String) async throws -> Action {
        Action(id: UUID(), name: name, ticker: ticker, secteur: secteur,
               quantity: quantity, dividendsTotal: 0)
    }

    func addShares(to action: Action, quantity: Int, token: String) async throws -> Action {
        if let error { throw error }
        addedShares = (action, quantity)
        return Action(id: action.id, name: action.name, ticker: action.ticker,
                      secteur: action.secteur, quantity: action.quantity + quantity,
                      dividendsTotal: action.dividendsTotal)
    }

    func addDividend(perShare: Double, paymentDate: Date, actionId: UUID,
                     token: String) async throws {}
}

private let airLiquide = Action(id: UUID(), name: "Air-liquide", ticker: "AI",
                                secteur: "Industrie", quantity: 1, dividendsTotal: 0)
private let nike = Action(id: UUID(), name: "Nike", ticker: "NKE",
                          secteur: "Consommation", quantity: 15, dividendsTotal: 354)

/// Renforcer une position depuis le portefeuille.
///
/// Aucun accès au trousseau : le jeton est injecté. Ces cas peuvent donc
/// tourner en parallèle de `TokenStoreTests`, qui s'y écrit vraiment.
@MainActor
struct AddSharesTests {

    private func viewModel(preselected: UUID? = nil,
                           service: FakePortfolioService) -> AddSharesViewModel {
        AddSharesViewModel(preselectedActionId: preselected,
                           service: service,
                           tokenProvider: { "test" })
    }

    /// L'écran s'ouvre sur la carte d'où l'on vient : le carrousel ne repart
    /// pas de la première ligne du portefeuille.
    @Test func leCarrouselSouvreSurLactionDorigine() async {
        let service = FakePortfolioService(portfolio: [airLiquide, nike])
        let sut = viewModel(preselected: nike.id, service: service)

        await sut.load()

        #expect(sut.selectedAction == nike)
    }

    /// Le compteur dit combien on achète, le rappel dit ce qu'on détiendra.
    @Test func leTotalAnnonceEstLaSomme() async {
        let service = FakePortfolioService(portfolio: [airLiquide])
        let sut = viewModel(preselected: airLiquide.id, service: service)

        await sut.load()
        sut.quantity = 2

        #expect(sut.totalAfter == 3)
    }

    /// Renforcer de zéro action ne veut rien dire : le compteur bute sur un,
    /// il ne descend pas à zéro comme celui de l'ajout d'une action.
    @Test func leCompteurNeDescendPasSousUn() {
        let service = FakePortfolioService(portfolio: [airLiquide])
        let sut = viewModel(service: service)

        sut.decrement()
        sut.decrement()

        #expect(sut.quantity == 1)
    }

    /// C'est bien la quantité achetée qui part au serveur, pas le nouveau
    /// total : c'est lui qui additionne.
    @Test func lenvoiPorteLaQuantiteAchetee() async {
        let service = FakePortfolioService(portfolio: [airLiquide])
        let sut = viewModel(preselected: airLiquide.id, service: service)

        await sut.load()
        sut.quantity = 2
        let saved = await sut.save()

        #expect(saved)
        #expect(service.addedShares?.quantity == 2)
        #expect(service.addedShares?.action == airLiquide)
        #expect(sut.errorMessage == nil)
    }

    /// Un portefeuille vide n'a rien à renforcer : l'envoi échoue sans partir.
    @Test func portefeuilleVideNenvoieRien() async {
        let service = FakePortfolioService(portfolio: [])
        let sut = viewModel(service: service)

        await sut.load()
        let saved = await sut.save()

        #expect(!saved)
        #expect(service.addedShares == nil)
        #expect(sut.errorMessage != nil)
    }

    /// Le jeton n'est plus accepté : l'écran demande une déconnexion plutôt
    /// que d'afficher une erreur que l'utilisateur ne peut pas résoudre.
    @Test func un401DemandeLaDeconnexion() async {
        let service = FakePortfolioService(portfolio: [airLiquide])
        let sut = viewModel(preselected: airLiquide.id, service: service)

        await sut.load()
        service.error = APIError.httpError(statusCode: 401, message: "Jeton expiré")
        let saved = await sut.save()

        #expect(!saved)
        #expect(sut.sessionExpired)
        #expect(sut.errorMessage == nil)
    }
}
