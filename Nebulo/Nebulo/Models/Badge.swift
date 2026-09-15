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
/// Ce catalogue est côté client faute d'endpoint : `users.grade` est une chaîne
/// que le serveur ne fait jamais évoluer, et aucune règle de passage n'existe
/// encore. Dès que le serveur pilotera le grade, cette liste devra venir de lui.
enum GradeCatalog {
    static let all: [Badge] = [
        Badge(image: "explorateur", name: "Explorateur"),
        Badge(image: "navigateur",  name: "Navigateur"),
        Badge(image: "astro",       name: "Astro"),
        Badge(image: "capitaine",   name: "Capitaine"),
        Badge(image: "commandant",  name: "Commandant"),
        Badge(image: "amiral",      name: "Amiral"),
        Badge(image: "maitre",      name: "Maître"),
        Badge(image: "seigneur",    name: "Seigneur")
    ]
}
