//
//  PostResponseDTO.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

/// Ce que renvoie `GET /posts`, en antéchronologique. C'est aussi ce que
/// renvoient les deux routes de vote, qui répondent avec le post remis à jour.
struct PostResponseDTO: Decodable {
    let id: UUID
    let content: String
    let dateOfCreated: Date

    let authorId: UUID
    let authorFirstname: String
    let authorAge: Int

    let companyId: UUID?
    let companyName: String?

    let hotCount: Int
    let coldCount: Int
    let myVote: VoteType?

    let responseCount: Int
}

/// Le corps de `PUT /posts/:id/vote`.
struct VoteRequestDTO: Encodable {
    let value: VoteType
}
