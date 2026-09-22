//
//  ResponseDTO.swift
//  Nebulo
//
//  Created by apprenant152 on 22/09/2026.
//

import Foundation

/// Ce que renvoie `GET /posts/:id/responses`, en chronologique — le contraire
/// du fil global, qui remonte les plus récents en tête : une conversation se
/// lit dans l'ordre où elle s'est tenue.
///
/// C'est aussi ce que renvoie `POST /posts/:id/responses`, avec la réponse
/// tout juste créée : la liste s'allonge sans avoir à la recharger entière.
struct ResponseDTO: Decodable {
    let id: UUID
    let content: String
    let dateOfCreated: Date

    let postId: UUID

    let authorId: UUID
    let authorFirstname: String
    let authorAge: Int
}

/// Le corps de `POST /posts/:id/responses`.
///
/// L'auteur est absent volontairement : le contrôleur le prend dans le jeton.
/// Le post visé est dans le chemin, pas dans le corps.
struct CreateResponseRequestDTO: Encodable {
    let content: String
}
