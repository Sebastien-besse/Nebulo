//
//  HomeUnlockDetectionTests.swift
//  NebuloTests
//
//  Created by apprenant152 on 23/09/2026.
//

import Foundation
import Testing
@testable import Nebulo

/// Un service d'accueil qui rend la réponse qu'on lui a posée, sans réseau.
/// Chaque `load()` consomme la suivante : c'est ce qui permet de rejouer deux
/// chargements successifs et d'observer ce que le second découvre.
private final class FakeHomeService: HomeServiceProtocol, @unchecked Sendable {
    typealias Response = (planets: [Planet], grade: UserGrade, challenge: Challenge?)

    private var responses: [Response]

    init(responses: [(planets: [Planet], grade: UserGrade)]) {
        self.responses = responses.map { ($0.planets, $0.grade, nil) }
    }

    init(responses: [Response]) {
        self.responses = responses
    }

    func loadDashboard(token: String) async throws
        -> (summary: DividendSummary, challenge: Challenge?, planets: [Planet], grade: UserGrade) {
        let next = responses.removeFirst()
        return (fakeSummary, next.challenge, next.planets, next.grade)
    }
}

/// Les huit planètes du référentiel, avec un seuil de déblocage à choisir.
/// Les identifiants sont stables d'un chargement à l'autre : c'est par eux que
/// le ViewModel reconnaît une planète déjà atteinte.
private let planetIDs = (0..<8).map { _ in UUID() }

private let thresholds = [0, 58, 108, 228, 778, 1427, 2871, 4497]
private let planetNames = ["Terre", "Mercure", "Vénus", "Mars",
                           "Jupiter", "Saturne", "Uranus", "Neptune"]

/// Le référentiel vu par un compte à `energy` points : tout ce qui est sous le
/// seuil est atteint, le reste est verrouillé.
private func planets(energy: Int) -> [Planet] {
    (0..<8).map { index in
        Planet(
            id: planetIDs[index],
            image: planetNames[index].lowercased(),
            name: planetNames[index],
            nickname: "",
            surface: 0,
            temperature: 0,
            description: "",
            energyThreshold: thresholds[index],
            locked: energy < thresholds[index],
            unlockedAt: energy < thresholds[index] ? nil : .now
        )
    }
}

private func grade(_ index: Int) -> UserGrade {
    UserGrade(
        xp: 100,
        current: GradeCatalog.all[index],
        next: index + 1 < GradeCatalog.all.count ? GradeCatalog.all[index + 1] : nil,
        progressPercent: 0,
        nextThreshold: nil
    )
}

/// Un challenge du pool, avec un identifiant à soi.
private func challenge(_ label: String, reward: Int = 30, completed: Bool = false) -> Challenge {
    Challenge(
        id: UUID(),
        description: label,
        type: .dividendCount,
        objectif: 5,
        energyReward: reward,
        assignedAt: .now,
        progress: 0,
        progressPercent: 0,
        completed: completed
    )
}

/// Ce que l'accueil retient quand plusieurs seuils tombent d'un coup.
///
/// Aucun accès au trousseau : le jeton est injecté. Ces cas peuvent donc
/// tourner en parallèle de `TokenStoreTests`, qui s'y écrit vraiment.
@MainActor
struct HomeUnlockDetectionTests {

    /// Un gros dividende peut franchir deux seuils entre deux chargements.
    /// Une seule célébration part alors, et c'est la plus lointaine : fêter
    /// Uranus puis Neptune ferait attendre deux fois pour un seul geste.
    @Test func deuxPlanetesDunCoupNeFetentQueLaPlusLointaine() async {
        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 1_500), grade(1)),   // jusqu'à Saturne
            (planets(energy: 5_000), grade(1))    // Uranus et Neptune d'un coup
        ]), tokenProvider: { "test" })

        await viewModel.load()
        #expect(viewModel.justUnlocked == nil, "Le premier chargement pose le repère, il ne fête rien")

        await viewModel.load()
        #expect(viewModel.justUnlocked?.name == "Neptune")
        #expect(viewModel.justPromoted == nil)
    }

    /// Le premier chargement ne doit rien fêter : sans repère, les huit
    /// planètes déjà atteintes passeraient pour des déblocages.
    @Test func premierChargementNeFeteRien() async {
        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 5_000), grade(3))
        ]), tokenProvider: { "test" })

        await viewModel.load()
        #expect(viewModel.justUnlocked == nil)
        #expect(viewModel.justPromoted == nil)
    }

    /// Deux planètes et un grade dans le même chargement : les deux
    /// célébrations sont armées, l'écran se charge de les ordonner.
    @Test func deuxPlanetesEtUnGradeArmentLesDeuxCelebrations() async {
        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 1_500), grade(1)),
            (planets(energy: 5_000), grade(3))
        ]), tokenProvider: { "test" })

        await viewModel.load()
        await viewModel.load()

        #expect(viewModel.justUnlocked?.name == "Neptune")
        #expect(viewModel.justPromoted?.name == "Commandant")
    }

    /// Une rétrogradation ne se fête pas : retirer une ligne du portefeuille
    /// fait redescendre, et l'XP se recalcule à chaque lecture.
    @Test func retrogradationNeSeFetePas() async {
        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 5_000), grade(3)),
            (planets(energy: 5_000), grade(1))
        ]), tokenProvider: { "test" })

        await viewModel.load()
        await viewModel.load()

        #expect(viewModel.justPromoted == nil)
    }

    /// Le serveur valide à la lecture : il crédite l'énergie, tire le suivant
    /// et le renvoie à la place du validé. C'est ce remplacement, et lui seul,
    /// qui dit au client qu'un challenge vient de tomber.
    @Test func leChallengeRemplaceSignaleUneValidation() async {
        let premier = challenge("Enregistre 5 dividendes")
        let second = challenge("Encaisse 100 € de dividendes")

        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 1_500), grade(1), premier),
            (planets(energy: 1_500), grade(1), second)
        ]), tokenProvider: { "test" })

        await viewModel.load()
        #expect(viewModel.justCompletedChallenge == nil, "Le premier chargement pose le repère")

        await viewModel.load()
        #expect(viewModel.justCompletedChallenge?.description == "Enregistre 5 dividendes")
        #expect(viewModel.challenge?.description == "Encaisse 100 € de dividendes")
    }

    /// Un challenge inchangé d'un chargement à l'autre n'est pas une
    /// validation : c'est simplement qu'on n'a pas avancé.
    @Test func leMemeChallengeNeFeteRien() async {
        let seul = challenge("Enregistre 5 dividendes")

        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 1_500), grade(1), seul),
            (planets(energy: 1_500), grade(1), seul)
        ]), tokenProvider: { "test" })

        await viewModel.load()
        await viewModel.load()

        #expect(viewModel.justCompletedChallenge == nil)
    }

    /// Au bout du pool, il n'y a plus de successeur à tirer : le serveur rend
    /// le challenge validé lui-même, drapeau levé.
    @Test func leDernierDuPoolSeFeteSurSonDrapeau() async {
        let dernier = challenge("Enregistre 5 dividendes")
        var valide = dernier
        valide = Challenge(
            id: dernier.id, description: dernier.description, type: dernier.type,
            objectif: dernier.objectif, energyReward: dernier.energyReward,
            assignedAt: dernier.assignedAt, progress: 5, progressPercent: 100,
            completed: true
        )

        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 1_500), grade(1), dernier),
            (planets(energy: 1_500), grade(1), valide)
        ]), tokenProvider: { "test" })

        await viewModel.load()
        await viewModel.load()

        #expect(viewModel.justCompletedChallenge?.completed == true)
    }

    /// Le cas complet : le challenge crédite l'énergie, l'énergie débloque
    /// deux planètes, les planètes font monter le grade. Les trois
    /// célébrations sont armées ensemble, l'écran les ordonne.
    @Test func lesTroisCelebrationsPeuventTomberEnsemble() async {
        let premier = challenge("Enregistre 5 dividendes")
        let second = challenge("Encaisse 100 € de dividendes")

        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 1_500), grade(1), premier),
            (planets(energy: 5_000), grade(3), second)
        ]), tokenProvider: { "test" })

        await viewModel.load()
        await viewModel.load()

        #expect(viewModel.justCompletedChallenge?.description == "Enregistre 5 dividendes")
        #expect(viewModel.justUnlocked?.name == "Neptune")
        #expect(viewModel.justPromoted?.name == "Commandant")
    }
}
