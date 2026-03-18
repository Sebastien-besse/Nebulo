//
//  Post.swift
//  Nebulo
//
//  Created by apprenant152 on 16/03/2026.
//

import Foundation

struct Post: Identifiable{
    let id = UUID()
    let nameUser: String
    var yearUser: String
    var content: String
    let dateOfCreated: Date
}

let fakePosts : [Post] = [
    Post(
        nameUser: "Paul",
         yearUser: "34 ans",
         content: "J'ai commencé à investir dans l'action Air Liquide il y a deux ans et pour moi c'est clairement une valeur solide. L'entreprise est très stable, verse des dividendes réguliers et son positionnement dans l'hydrogène et les gaz industriels me semble prometteur sur le long terme. Évidemment ce n'est pas une action pour faire un coup rapide, mais plutôt pour construire un portefeuille sur la durée.",
         dateOfCreated: .now
        ),
    Post(
        nameUser: "Mathis",
         yearUser: "28 ans",
         content: "J'ai commencé à investir dans l'action Air Liquide il y a 1 ans et pour moi c'est clairement une valeur solide. L'entreprise est très stable, verse des dividendes réguliers et son positionnement dans l'hydrogène et les gaz industriels me semble prometteur sur le long terme. De plus l'entrepsirse est clairement leader sur le marché européen et n'as quasiment aucun concurrent.",
         dateOfCreated: .now
        ),
    Post(
        nameUser: "Thibault",
         yearUser: "33 ans",
         content: "J'ai investi dans l'action Air Liquide il y a 8 ans et pour moi c'est l'un de mes meilleurs investissment à ce jour. L'entreprise est solide, verse des dividendes réguliers et son positionnement dans l'hydrogène et les gaz industriels me semble prometteur sur le long terme. Elle également en perpetuel croissance malgré les différent projet dans lequel elle investi énormément",
         dateOfCreated: .now
        )
]
