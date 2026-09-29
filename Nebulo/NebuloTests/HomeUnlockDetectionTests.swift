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
    /// `justCompleted` : le challenge que le serveur annonce avoir validé
    /// pendant ce chargement.
    typealias Response = (planets: [Planet], grade: UserGrade, challenge: Challenge?, justCompleted: Challenge?)

    private var responses: [Response]

    init(responses: [(planets: [Planet], grade: UserGrade)]) {
        self.responses = responses.map { ($0.planets, $0.grade, nil, nil) }
    }

    init(responses: [Response]) {
        self.responses = responses
    }

    func loadDashboard(token: String) async throws
        -> (summary: DividendSummary, challenge: Challenge?, justCompleted: Challenge?, planets: [Planet], grade: UserGrade) {
        let next = responses.removeFirst()
        return (fakeSummary, next.challenge, next.justCompleted, next.planets, next.grade)
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

/// Le même challenge, objectif atteint, tel que le serveur l'annonce.
private func validated(_ challenge: Challenge) -> Challenge {
    Challenge(
        id: challenge.id, description: challenge.description, type: challenge.type,
        objectif: challenge.objectif, energyReward: challenge.energyReward,
        assignedAt: challenge.assignedAt, progress: Double(challenge.objectif),
        progressPercent: 100, completed: true
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

    /// Le serveur valide à la lecture : il crédite l'énergie, tire le suivant,
    /// le renvoie à la place du validé, et annonce ce dernier. C'est cette
    /// annonce, et elle seule, qui déclenche la célébration.
    @Test func leServeurAnnonceLaValidation() async {
        let premier = challenge("Enregistre 5 dividendes")
        let second = challenge("Encaisse 3 € de dividendes")

        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 1_500), grade(1), premier, nil),
            (planets(energy: 1_500), grade(1), second, validated(premier))
        ]), tokenProvider: { "test" })

        await viewModel.load()
        #expect(viewModel.justCompletedChallenge == nil)

        await viewModel.load()
        #expect(viewModel.justCompletedChallenge?.description == "Enregistre 5 dividendes")
        #expect(viewModel.challenge?.description == "Encaisse 3 € de dividendes")
    }

    /// Le point 4.4 : l'app vient d'être lancée, et son tout premier chargement
    /// valide le challenge. Il n'y a pas de chargement précédent auquel
    /// comparer, la célébration part quand même.
    @Test func premierChargementFeteUneValidation() async {
        let premier = challenge("Enregistre 5 dividendes")
        let second = challenge("Encaisse 3 € de dividendes")

        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 1_500), grade(1), second, validated(premier))
        ]), tokenProvider: { "test" })

        await viewModel.load()

        #expect(viewModel.justCompletedChallenge?.description == "Enregistre 5 dividendes")
    }

    /// Un challenge désactivé est remplacé par un autre sans avoir été validé :
    /// le challenge change, mais rien n'a été gagné, et rien ne se fête.
    @Test func unChallengeRemplaceSansAnnonceNeFeteRien() async {
        let retire = challenge("Enregistre 5 dividendes")
        let remplacant = challenge("Encaisse 3 € de dividendes")

        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 1_500), grade(1), retire, nil),
            (planets(energy: 1_500), grade(1), remplacant, nil)
        ]), tokenProvider: { "test" })

        await viewModel.load()
        await viewModel.load()

        #expect(viewModel.justCompletedChallenge == nil)
        #expect(viewModel.challenge?.description == "Encaisse 3 € de dividendes")
    }

    /// Un challenge inchangé d'un chargement à l'autre n'est pas une
    /// validation : c'est simplement qu'on n'a pas avancé.
    @Test func leMemeChallengeNeFeteRien() async {
        let seul = challenge("Enregistre 5 dividendes")

        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 1_500), grade(1), seul, nil),
            (planets(energy: 1_500), grade(1), seul, nil)
        ]), tokenProvider: { "test" })

        await viewModel.load()
        await viewModel.load()

        #expect(viewModel.justCompletedChallenge == nil)
    }

    /// Au bout du pool, il n'y a plus de successeur à tirer : le serveur rend
    /// le challenge validé lui-même, et l'annonce.
    @Test func leDernierDuPoolSeFete() async {
        let dernier = challenge("Enregistre 5 dividendes")

        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 1_500), grade(1), dernier, nil),
            (planets(energy: 1_500), grade(1), validated(dernier), validated(dernier))
        ]), tokenProvider: { "test" })

        await viewModel.load()
        await viewModel.load()

        #expect(viewModel.justCompletedChallenge?.completed == true)
        #expect(viewModel.justCompletedChallenge?.id == viewModel.challenge?.id,
                "Même identifiant : l'écran en déduit qu'il n'y a pas de suivant")
    }

    /// Le cas complet : le challenge crédite l'énergie, l'énergie débloque
    /// deux planètes, les planètes font monter le grade. Les trois
    /// célébrations sont armées ensemble, l'écran les ordonne.
    @Test func lesTroisCelebrationsPeuventTomberEnsemble() async {
        let premier = challenge("Enregistre 5 dividendes")
        let second = challenge("Encaisse 3 € de dividendes")

        let viewModel = HomeViewModel(service: FakeHomeService(responses: [
            (planets(energy: 1_500), grade(1), premier, nil),
            (planets(energy: 5_000), grade(3), second, validated(premier))
        ]), tokenProvider: { "test" })

        await viewModel.load()
        await viewModel.load()

        #expect(viewModel.justCompletedChallenge?.description == "Enregistre 5 dividendes")
        #expect(viewModel.justUnlocked?.name == "Neptune")
        #expect(viewModel.justPromoted?.name == "Commandant")
    }
}
