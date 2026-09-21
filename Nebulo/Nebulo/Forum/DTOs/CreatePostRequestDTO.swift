//
//  CreatePostRequestDTO.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

/// Ce que le client envoie à `POST /posts`.
///
/// L'auteur est absent volontairement : le contrôleur le prend dans le jeton.
/// `companyId` reste facultatif, un message peut ne viser aucune entreprise.
struct CreatePostRequestDTO: Encodable {
    let content: String
    let companyId: UUID?
}
