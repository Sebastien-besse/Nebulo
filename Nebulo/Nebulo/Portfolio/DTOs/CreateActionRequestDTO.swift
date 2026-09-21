//
//  CreateActionRequestDTO.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

/// Ce que le client envoie à `POST /actions`.
///
/// `userId` est absent volontairement : le contrôleur le prend dans le jeton
/// et écrase tout ce que le corps prétendrait. L'envoyer laisserait croire
/// qu'on peut créer une action dans le portefeuille d'un tiers.
struct CreateActionRequestDTO: Encodable {
    let name: String
    let ticker: String
    let secteur: String
    let quantity: Int
}
