//
//  Post.swift
//  Nebulo
//
//  Created by apprenant152 on 16/03/2026.
//

import Foundation

/// Le vote d'un lecteur sur un post. Chaud ou froid, jamais les deux :
/// la contrainte `UNIQUE(user_id, post_id)` n'en laisse passer qu'un.
enum VoteType: String, Codable {
    case hot = "HOT"
    case cold = "COLD"
}

/// Un message du forum, avec son auteur, l'entreprise dont il parle et le
/// décompte des votes.
///
/// L'identifiant vient du serveur : le générer ici le perdrait, et voter
/// deviendrait impossible faute de savoir sur quel post porter le vote.
/// `Equatable` est exigé par le carrousel de l'écran Société, qui compare
/// les éléments pour savoir lequel est au centre.
struct Post: Identifiable, Equatable {
    let id: UUID
    let content: String
    let dateOfCreated: Date

    let authorId: UUID
    let authorFirstname: String
    /// Âge en années, calculé côté serveur depuis la date de naissance.
    let authorAge: Int

    let companyId: UUID?
    /// Absent quand le post ne vise aucune entreprise, ou que celle-ci a été
    /// supprimée — la clé étrangère est en SET NULL.
    let companyName: String?

    let hotCount: Int
    let coldCount: Int
    /// Le vote du lecteur sur ce post, s'il en a émis un.
    let myVote: VoteType?

    let responseCount: Int
}

/// Fil d'exemple pour les previews.
let fakePosts: [Post] = [
    Post(
        id: UUID(),
        content: "J'ai commencé à investir dans l'action Air Liquide il y a deux ans et pour moi c'est clairement une valeur solide. L'entreprise est très stable, verse des dividendes réguliers et son positionnement dans l'hydrogène et les gaz industriels me semble prometteur sur le long terme. Évidemment ce n'est pas une action pour faire un coup rapide, mais plutôt pour construire un portefeuille sur la durée.",
        dateOfCreated: Date(timeIntervalSince1970: 1_771_632_000),
        authorId: UUID(), authorFirstname: "Paul", authorAge: 34,
        companyId: UUID(), companyName: "Air-liquide",
        hotCount: 12, coldCount: 1, myVote: .hot, responseCount: 3
    ),
    Post(
        id: UUID(),
        content: "Tesla reste très volatile et ne verse aucun dividende. Je l'ai en portefeuille pour la croissance, pas pour le revenu — ce n'est pas la même logique que le reste de mes positions.",
        dateOfCreated: Date(timeIntervalSince1970: 1_771_286_400),
        authorId: UUID(), authorFirstname: "Mathis", authorAge: 28,
        companyId: UUID(), companyName: "Tesla",
        hotCount: 4, coldCount: 9, myVote: .cold, responseCount: 7
    ),
    Post(
        id: UUID(),
        content: "Apple a augmenté son dividende chaque année depuis 2012. Le rendement est faible mais la progression est régulière, et les rachats d'actions font le reste.",
        dateOfCreated: Date(timeIntervalSince1970: 1_768_348_800),
        authorId: UUID(), authorFirstname: "Thibault", authorAge: 33,
        companyId: UUID(), companyName: "Apple",
        hotCount: 21, coldCount: 2, myVote: nil, responseCount: 5
    ),
    Post(
        id: UUID(),
        content: "Nestlé est ma position défensive par excellence. Le dividende progresse doucement mais il n'a jamais été coupé, même en 2020.",
        dateOfCreated: Date(timeIntervalSince1970: 1_750_118_400),
        authorId: UUID(), authorFirstname: "Sophie", authorAge: 41,
        companyId: UUID(), companyName: "Nestle",
        hotCount: 8, coldCount: 0, myVote: nil, responseCount: 1
    ),
    Post(
        id: UUID(),
        content: "Microsoft combine croissance et dividende croissant, ce qui est rare. C'est la ligne que je renforce le plus régulièrement.",
        dateOfCreated: Date(timeIntervalSince1970: 1_750_118_400),
        authorId: UUID(), authorFirstname: "Lucas", authorAge: 26,
        companyId: UUID(), companyName: "Microsoft",
        hotCount: 15, coldCount: 3, myVote: nil, responseCount: 2
    ),
    Post(
        id: UUID(),
        content: "Coca-Cola augmente son dividende depuis plus de 60 ans d'affilée. C'est le genre de régularité qui rend le calcul de revenu passif prévisible.",
        dateOfCreated: Date(timeIntervalSince1970: 1_750_118_400),
        authorId: UUID(), authorFirstname: "Camille", authorAge: 38,
        companyId: UUID(), companyName: "Coca-cola",
        hotCount: 17, coldCount: 1, myVote: nil, responseCount: 4
    ),
    // Un post sans entreprise : la clé est facultative côté API.
    Post(
        id: UUID(),
        content: "Question de débutant : vaut-il mieux réinvestir ses dividendes ou les encaisser pour financer autre chose ?",
        dateOfCreated: Date(timeIntervalSince1970: 1_749_513_600),
        authorId: UUID(), authorFirstname: "Julie", authorAge: 31,
        companyId: nil, companyName: nil,
        hotCount: 6, coldCount: 0, myVote: nil, responseCount: 11
    )
]
