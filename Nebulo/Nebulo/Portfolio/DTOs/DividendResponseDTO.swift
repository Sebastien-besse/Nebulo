//
//  DividendResponseDTO.swift
//  Nebulo
//
//  Created by apprenant152 on 18/09/2026.
//

import Foundation

/// Ce que renvoie `GET /dividends`, en antéchronologique.
///
/// `total` est figé à l'enregistrement : c'est `dividendPerShare` multiplié
/// par la quantité détenue ce jour-là, pas par la quantité actuelle. Le
/// cumul par action se somme donc sans jamais consulter l'action elle-même.
struct DividendResponseDTO: Decodable {
    let id: UUID
    let dividendPerShare: Double
    let paymentDate: Date
    let actionId: UUID
    let actionName: String
    let actionTicker: String
    let quantityAtPayment: Int
    let total: Double
}
