//
//  CreateDividendRequestDTO.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

/// Ce que le client envoie à `POST /dividends`.
///
/// Ni la quantité ni le total n'y figurent : le serveur lit la quantité
/// détenue à cet instant et fige les deux sur la ligne. C'est ce qui empêche
/// qu'acheter des actions plus tard réécrive l'historique.
struct CreateDividendRequestDTO: Encodable {
    let dividendPerShare: Double
    let paymentDate: Date
    let actionId: UUID
}
