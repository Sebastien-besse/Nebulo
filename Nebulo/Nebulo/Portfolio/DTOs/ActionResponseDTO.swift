//
//  ActionResponseDTO.swift
//  Nebulo
//
//  Created by apprenant152 on 18/09/2026.
//

import Foundation

/// Ce que renvoie `GET /users/:userID/actions`.
///
/// `userId` est bien présent dans la réponse mais n'est pas repris : l'écran
/// n'affiche que le portefeuille du porteur du jeton, la propriété est déjà
/// garantie par l'API qui renvoie 403 si l'identifiant ne correspond pas.
struct ActionResponseDTO: Decodable {
    let id: UUID
    let name: String
    let ticker: String
    let secteur: String
    let quantity: Int
}
