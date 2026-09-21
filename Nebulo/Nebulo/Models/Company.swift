//
//  Company.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

/// Une entreprise du référentiel. En lecture seule côté API : laisser chacun
/// créer la sienne ferait cohabiter « Air Liquide », « air liquide » et
/// « AirLiquide ».
/// `Equatable` est exigé par le carrousel de l'écran Post, qui compare les
/// éléments pour savoir lequel est au centre.
struct Company: Identifiable, Equatable {
    let id: UUID
    let name: String
    let secteur: String
    let description: String
}

/// Entreprise d'exemple pour les previews.
let fakeCompany = Company(
    id: UUID(),
    name: "Air-liquide",
    secteur: "Industrie",
    description: "Air Liquide est un groupe français spécialisé dans la production et la distribution de gaz industriels et médicaux, présent dans plus de 70 pays."
)
