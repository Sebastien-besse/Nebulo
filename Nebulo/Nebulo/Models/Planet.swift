//
//  Planet.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import Foundation

/// Une planète telle que l'utilisateur la voit : la fiche du référentiel, plus
/// l'état de sa propre progression.
///
/// `id` vient du serveur et n'est pas régénéré localement : sans lui, impossible
/// de désigner une planète auprès de l'API.
struct Planet: Identifiable, Equatable {
    let id: UUID
    /// Nom de l'asset à afficher (« earth », « jupiter »…). C'est le serveur qui
    /// le donne, plutôt que de le déduire du nom — « Vénus » et « Terre » ne
    /// correspondent pas à leurs fichiers.
    let image: String
    let name: String
    let nickname: String
    /// Diamètre, en kilomètres.
    let surface: Int
    /// Température moyenne de surface, en degrés Celsius.
    let temperature: Int
    let description: String
    let energyThreshold: Int
    let locked: Bool
    let unlockedAt: Date?
}

/// Les huit planètes vues par un compte à 80 points d'énergie : Terre et
/// Mercure atteintes, les six autres encore hors de portée. Sert aux previews.
let fakePlanets: [Planet] = [
    Planet(id: UUID(), image: "earth",   name: "Terre",   nickname: "La planète bleue",
           surface: 12742, temperature: 15,
           description: "Ton point de départ. La base de lancement de ton vaisseau.",
           energyThreshold: 0, locked: false, unlockedAt: .now),
    Planet(id: UUID(), image: "mercure", name: "Mercure", nickname: "Le monde brûlé",
           surface: 4879, temperature: 167,
           description: "La plus petite planète du système solaire et la plus proche du Soleil.",
           energyThreshold: 58, locked: false, unlockedAt: .now),
    Planet(id: UUID(), image: "venus",   name: "Vénus",   nickname: "L'étoile du berger",
           surface: 12104, temperature: 464,
           description: "La planète la plus chaude, sous une épaisse atmosphère de dioxyde de carbone.",
           energyThreshold: 108, locked: true, unlockedAt: nil),
    Planet(id: UUID(), image: "mars",    name: "Mars",    nickname: "La planète rouge",
           surface: 6779, temperature: -63,
           description: "Couverte d'oxyde de fer. Elle abrite le plus haut volcan du système solaire.",
           energyThreshold: 228, locked: true, unlockedAt: nil),
    Planet(id: UUID(), image: "jupiter", name: "Jupiter", nickname: "La géante",
           surface: 139820, temperature: -145,
           description: "Deux fois plus massive que toutes les autres planètes réunies.",
           energyThreshold: 778, locked: true, unlockedAt: nil),
    Planet(id: UUID(), image: "saturn",  name: "Saturne", nickname: "Le seigneur des anneaux",
           surface: 116460, temperature: -178,
           description: "Reconnaissable à ses anneaux de glace et de roche.",
           energyThreshold: 1427, locked: true, unlockedAt: nil),
    Planet(id: UUID(), image: "uranus",  name: "Uranus",  nickname: "La géante de glace",
           surface: 50724, temperature: -224,
           description: "Elle tourne presque couchée sur le côté, créant des saisons extrêmes.",
           energyThreshold: 2871, locked: true, unlockedAt: nil),
    Planet(id: UUID(), image: "neptune", name: "Neptune", nickname: "La lointaine",
           surface: 49244, temperature: -214,
           description: "Balayée par les vents les plus violents du système solaire.",
           energyThreshold: 4497, locked: true, unlockedAt: nil)
]
