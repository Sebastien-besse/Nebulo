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
        content: "J'ai commencé à investir dans l'action Air Liquide il y a 1 ans et pour moi c'est clairement une valeur solide. L'entreprise est très stable, verse des dividendes réguliers et son positionnement dans l'hydrogène et les gaz industriels me semble prometteur sur le long terme. De plus l'entreprise est clairement leader sur le marché européen et n'a quasiment aucun concurrent.",
        dateOfCreated: .now
    ),
    Post(
        nameUser: "Thibault",
        yearUser: "33 ans",
        content: "J'ai investi dans l'action Air Liquide il y a 8 ans et pour moi c'est l'un de mes meilleurs investissements à ce jour. L'entreprise est solide, verse des dividendes réguliers et son positionnement dans l'hydrogène et les gaz industriels me semble prometteur sur le long terme. Elle est également en perpétuelle croissance malgré les différents projets dans lesquels elle investit énormément.",
        dateOfCreated: .now
    ),
    Post(
        nameUser: "Sophie",
        yearUser: "41 ans",
        content: "TotalEnergies fait partie de mon portefeuille depuis 5 ans maintenant. Le dividende est généreux et relativement stable même dans les périodes de volatilité du pétrole. J'apprécie aussi leur transition vers les énergies renouvelables, ce qui rassure sur la pérennité du modèle à long terme.",
        dateOfCreated: Calendar.current.date(byAdding: .day, value: -2, to: .now)!
    ),
    Post(
        nameUser: "Lucas",
        yearUser: "26 ans",
        content: "Je débute dans l'investissement en dividendes et j'ai choisi LVMH comme première position. Le rendement en dividendes n'est pas le plus élevé, mais la qualité des marques et la croissance régulière du dividende depuis 20 ans m'ont convaincu. C'est une façon de combiner croissance et revenu passif.",
        dateOfCreated: Calendar.current.date(byAdding: .day, value: -5, to: .now)!
    ),
    Post(
        nameUser: "Camille",
        yearUser: "38 ans",
        content: "Schneider Electric est selon moi l'une des valeurs les plus intéressantes du CAC 40 pour les investisseurs long terme. La transition énergétique joue clairement en leur faveur et les dividendes ont progressé chaque année depuis plus de 10 ans. Je continue à renforcer ma position progressivement.",
        dateOfCreated: Calendar.current.date(byAdding: .day, value: -7, to: .now)!
    ),
    Post(
        nameUser: "Antoine",
        yearUser: "52 ans",
        content: "J'investis dans les REITs américains depuis plusieurs années pour maximiser mes revenus passifs. Realty Income verse des dividendes mensuels ce qui est rare et très appréciable pour lisser ses revenus. Le rendement tourne autour de 5% ce qui est très correct pour une valeur de cette qualité.",
        dateOfCreated: Calendar.current.date(byAdding: .day, value: -10, to: .now)!
    ),
    Post(
        nameUser: "Julie",
        yearUser: "31 ans",
        content: "Sanofi est dans mon portefeuille principalement pour la régularité de ses dividendes. Le secteur pharmaceutique offre une bonne résilience en période de crise et Sanofi a su maintenir et augmenter son dividende même pendant les années difficiles. C'est une valeur défensive idéale pour équilibrer un portefeuille.",
        dateOfCreated: Calendar.current.date(byAdding: .day, value: -14, to: .now)!
    ),
]
