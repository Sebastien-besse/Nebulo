//
//  PostResponse.swift
//  Nebulo
//
//  Created by apprenant152 on 22/09/2026.
//

import Foundation

/// La réponse d'un lecteur à un message du forum.
///
/// L'identifiant vient du serveur, comme pour `Post` : le générer ici le
/// perdrait, et il n'y aurait plus de quoi désigner la ligne à supprimer.
/// `Hashable` est exigé par la pile de navigation, qui transporte le post
/// ouvert jusqu'à son fil.
struct PostResponse: Identifiable, Equatable, Hashable {
    let id: UUID
    let content: String
    let dateOfCreated: Date

    /// Le message auquel la réponse se rattache. Jamais nul : la clé étrangère
    /// est en CASCADE, une réponse ne survit pas à son post.
    let postId: UUID

    let authorId: UUID
    let authorFirstname: String
    /// Âge en années, calculé côté serveur depuis la date de naissance.
    let authorAge: Int
}

/// Fil de réponses d'exemple pour les previews.
let fakeResponses: [PostResponse] = [
    PostResponse(
        id: UUID(),
        content: "Même avis sur la régularité du dividende. En revanche l'hydrogène reste une promesse : les volumes ne sont pas encore là.",
        dateOfCreated: Date(timeIntervalSince1970: 1_771_718_400),
        postId: fakePosts[0].id,
        authorId: UUID(), authorFirstname: "Mathis", authorAge: 28
    ),
    PostResponse(
        id: UUID(),
        content: "Tu la gardes en direct ou via un PEA ? La fiscalité change pas mal le rendement net sur ce genre de ligne.",
        dateOfCreated: Date(timeIntervalSince1970: 1_771_804_800),
        postId: fakePosts[0].id,
        authorId: UUID(), authorFirstname: "Sophie", authorAge: 41
    ),
    // L'auteur du message répond dans son propre fil : rien ne l'en empêche,
    // contrairement au vote.
    PostResponse(
        id: UUID(),
        content: "PEA ici aussi. Deux ans de détention et je n'ai rien vendu, donc pour l'instant la question ne s'est pas posée.",
        dateOfCreated: Date(timeIntervalSince1970: 1_771_891_200),
        postId: fakePosts[0].id,
        authorId: fakePosts[0].authorId,
        authorFirstname: fakePosts[0].authorFirstname,
        authorAge: fakePosts[0].authorAge
    )
]
