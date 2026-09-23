//
//  HomeViewModel.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var summary: DividendSummary? = nil
    /// Nil quand le pool est épuisé : tous les challenges ont été validés.
    @Published var challenge: Challenge? = nil
    @Published var planets: [Planet] = []
    /// Le grade acquis. Il s'affiche dans le hublot de la fusée, derrière le
    /// verre. Nil tant que le serveur n'a pas répondu.
    @Published var grade: UserGrade? = nil
    /// Renseignée quand un rechargement découvre une planète qui ne l'était
    /// pas au précédent. L'écran s'en sert pour fêter le franchissement.
    @Published var justUnlocked: Planet? = nil
    /// Renseigné quand un rechargement découvre un grade plus élevé que celui
    /// du précédent. Même rôle que `justUnlocked`, pour la promotion.
    @Published var justPromoted: Badge? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    /// Vrai une fois que le serveur a répondu. Sert à distinguer « aucun
    /// challenge à tirer » d'un chargement qui a échoué : les deux laissent le
    /// challenge nil, mais ne se disent pas de la même façon.
    @Published var hasLoaded: Bool = false
    /// Vrai dès qu'un chargement a été tenté, abouti ou non. Les previews le
    /// mettent à vrai pour que l'écran n'aille jamais toucher le trousseau ni
    /// le réseau, dont elles ne disposent pas.
    @Published var hasAttemptedLoad: Bool = false
    /// Vrai quand le jeton n'est plus accepté : l'écran demande alors une
    /// déconnexion plutôt que d'afficher une erreur insoluble.
    @Published var sessionExpired: Bool = false

    /// Les planètes atteintes au dernier chargement. Nil tant qu'il n'y en a
    /// pas eu : sans ce repère, le tout premier chargement ferait passer les
    /// huit pour des déblocages.
    private var knownUnlocked: Set<UUID>? = nil

    /// Le grade du dernier chargement, pour la même raison : sans ce repère,
    /// la première réponse du serveur se lirait comme une promotion.
    private var knownGrade: String? = nil

    private let service: HomeServiceProtocol

    // La valeur par défaut est construite dans le corps : évaluée comme
    // argument par défaut, elle le serait hors de l'acteur principal.
    init(service: HomeServiceProtocol? = nil) {
        self.service = service ?? HomeService()
    }

    /// L'asset du grade acquis, pour le hublot. Nil avant la réponse du
    /// serveur, ou si le référentiel des grades était vide.
    var gradeImage: String? { grade?.current?.image }

    /// Le cumul de toujours, arrondi au centime. C'est le chiffre de tête du
    /// tableau de bord : ce que le portefeuille a rapporté en tout.
    var totalLabel: String {
        guard let summary else { return "—" }
        return summary.totalAllTime
            .formatted(.number.precision(.fractionLength(2))) + " €"
    }

    /// Le même cumul, sans la devise. La carte d'accueil pose le « € » à
    /// part, plus petit : le chiffre reste alors seul à porter, et deux
    /// montants de longueurs différentes s'alignent sur la même virgule.
    var totalAmountLabel: String {
        guard let summary else { return "—" }
        return summary.totalAllTime
            .formatted(.number.precision(.fractionLength(2)))
    }

    /// La planète la plus lointaine parmi celles déjà atteintes : c'est elle
    /// que le vaisseau survole sur l'accueil.
    ///
    /// Le critère est le seuil, pas la date de déblocage. Les deux donnent le
    /// même résultat — une planète atteinte ne se reverrouille jamais, donc on
    /// progresse toujours vers le plus lointain — mais le seuil ne dépend pas
    /// d'un horodatage.
    var currentPlanet: Planet? {
        planets
            .filter { !$0.locked }
            .max { $0.energyThreshold < $1.energyThreshold }
    }

    /// La planète la plus proche encore hors de portée : la prochaine étape.
    var nextPlanet: Planet? {
        planets
            .filter { $0.locked }
            .min { $0.energyThreshold < $1.energyThreshold }
    }

    /// Avancée vers la prochaine planète, de 0 à 1. C'est ce que remplit le
    /// vaisseau de l'accueil.
    ///
    /// La mesure part du seuil déjà franchi, pas de zéro : entre Jupiter (778)
    /// et Saturne (1427), 800 points valent 3 % du trajet, pas 56 %. Rapporter
    /// l'énergie au seuil absolu ferait une jauge qui n'avance plus.
    var energyProgress: Double {
        guard let next = nextPlanet else { return 1 }
        let reached = currentPlanet?.energyThreshold ?? 0
        let span = Double(next.energyThreshold - reached)
        guard span > 0 else { return 1 }
        let travelled = Double((summary?.energy ?? 0) - reached)
        return min(1, max(0, travelled / span))
    }

    /// La Terre est débloquée dès l'inscription, son seuil valant zéro. Le
    /// repli ne sert donc qu'au temps du chargement.
    var currentPlanetImage: String {
        currentPlanet?.image ?? "earth"
    }

    /// Compare les planètes atteintes à celles du chargement précédent. Si
    /// plusieurs tombent d'un coup — un gros dividende peut en franchir deux —
    /// on retient la plus lointaine, celle qui compte.
    private func detectUnlock(in planets: [Planet]) {
        let unlockedNow = Set(planets.filter { !$0.locked }.map(\.id))
        defer { knownUnlocked = unlockedNow }

        guard let known = knownUnlocked else { return }
        justUnlocked = planets
            .filter { unlockedNow.subtracting(known).contains($0.id) }
            .max { $0.energyThreshold < $1.energyThreshold }
    }

    /// Compare le grade reçu à celui du chargement précédent.
    ///
    /// Seule la montée est fêtée. L'XP n'est pas stockée, elle se recalcule à
    /// chaque lecture : retirer une ligne du portefeuille fait redescendre, et
    /// une rétrogradation célébrée serait une moquerie.
    private func detectPromotion(in grade: UserGrade?) {
        guard let current = grade?.current else { return }
        defer { knownGrade = current.name }

        guard let known = knownGrade,
              known.lowercased() != current.name.lowercased(),
              let knownRank = GradeCatalog.rank(ofName: known),
              let newRank = GradeCatalog.rank(ofName: current.name),
              newRank > knownRank
        else { return }

        justPromoted = current
    }

    func load() async {
        hasAttemptedLoad = true
        guard let token = TokenStore.shared.token else {
            sessionExpired = true
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let (summary, challenge, planets, grade) = try await service.loadDashboard(token: token)
            self.summary = summary
            self.challenge = challenge
            self.planets = planets
            self.grade = grade
            detectUnlock(in: planets)
            detectPromotion(in: grade)
            self.hasLoaded = true
        } catch APIError.httpError(let statusCode, _) where statusCode == 401 {
            sessionExpired = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Une erreur est survenue"
        }
        isLoading = false
    }
}
