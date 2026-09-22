//
//  Badge.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import Foundation

struct Badge: Identifiable, Equatable {
    let id: String
    /// Nom de l'asset dans Assets.xcassets/Badges.
    let image: String
    let name: String

    init(image: String, name: String) {
        self.id = image
        self.image = image
        self.name = name
    }
}

/// Les huit grades, dans l'ordre de progression.
///
/// L'ordre reproduit la table `grades`, qui fait désormais foi — Commandant
/// avant Capitaine. Ce catalogue ne sert plus qu'au carrousel du profil, qui
/// montre le chemin entier ; le grade courant, lui, vient du serveur.
enum GradeCatalog {
    static let all: [Badge] = [
        Badge(image: "explorateur", name: "Explorateur"),
        Badge(image: "navigateur",  name: "Navigateur"),
        Badge(image: "astro",       name: "Astro"),
        Badge(image: "commandant",  name: "Commandant"),
        Badge(image: "capitaine",   name: "Capitaine"),
        Badge(image: "amiral",      name: "Amiral"),
        Badge(image: "maitre",      name: "Maître"),
        Badge(image: "seigneur",    name: "Seigneur")
    ]
}

/// Le grade acquis et le prochain palier, tels que les renvoie `GET /grades/me`.
///
/// L'XP n'est stockée nulle part : le serveur la recalcule à chaque lecture
/// depuis les planètes atteintes, les challenges validés et les jours de
/// connexion.
struct UserGrade {
    let xp: Int
    /// Absent seulement si le référentiel est vide.
    let current: Badge?
    /// Absent une fois le dernier grade atteint.
    let next: Badge?
    /// Avancement vers le grade suivant, de 0 à 100. Vaut 100 au sommet.
    let progressPercent: Double
    /// Palier du grade suivant, pour afficher « 105 / 250 ».
    let nextThreshold: Int?
}

/// Progression d'exemple pour les previews.
let fakeUserGrade = UserGrade(
    xp: 105,
    current: GradeCatalog.all[1],
    next: GradeCatalog.all[2],
    progressPercent: 3.3,
    nextThreshold: 250
)
