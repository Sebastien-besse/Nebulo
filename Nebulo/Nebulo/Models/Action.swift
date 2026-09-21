//
//  Action.swift
//  Nebulo
//
//  Created by apprenant152 on 18/09/2026.
//

import Foundation

/// Une ligne du portefeuille : l'action détenue et le cumul des dividendes
/// qu'elle a versés.
///
/// L'API renvoie les deux séparément — `GET /users/:id/actions` d'un côté,
/// `GET /dividends` de l'autre. Le service les assemble ici parce que c'est
/// ainsi que l'écran les lit : une carte montre toujours les deux ensemble.
/// `Equatable` est exigé par le carrousel de la saisie d'un dividende, qui
/// compare les éléments pour savoir lequel est au centre.
struct Action: Identifiable, Equatable {
    let id: UUID
    let name: String
    let ticker: String
    let secteur: String
    let quantity: Int
    let dividendsTotal: Double
}

/// Portefeuille d'exemple pour les previews.
///
/// Les trois premières lignes reprennent la maquette. Les suivantes couvrent
/// ce que la maquette ne montre pas : un nom long qui doit se réduire dans la
/// puce, une quantité et un cumul à quatre chiffres, et une ligne encore sans
/// dividende.
let fakeActions: [Action] = [
    Action(id: UUID(), name: "Air-liquide", ticker: "AI", secteur: "Industrie",
           quantity: 12, dividendsTotal: 124),
    Action(id: UUID(), name: "Nike", ticker: "NKE", secteur: "Consommation",
           quantity: 15, dividendsTotal: 354),
    Action(id: UUID(), name: "Nestle", ticker: "NESN", secteur: "Agroalimentaire",
           quantity: 34, dividendsTotal: 602),
    Action(id: UUID(), name: "TotalEnergies", ticker: "TTE", secteur: "Énergie",
           quantity: 48, dividendsTotal: 1284),
    Action(id: UUID(), name: "Sanofi", ticker: "SAN", secteur: "Santé",
           quantity: 21, dividendsTotal: 789),
    Action(id: UUID(), name: "LVMH", ticker: "MC", secteur: "Luxe",
           quantity: 3, dividendsTotal: 195),
    Action(id: UUID(), name: "Michelin", ticker: "ML", secteur: "Industrie",
           quantity: 60, dividendsTotal: 810),
    Action(id: UUID(), name: "Apple", ticker: "AAPL", secteur: "Tech",
           quantity: 125, dividendsTotal: 1046),
    Action(id: UUID(), name: "Rivian", ticker: "RIVN", secteur: "Automobile",
           quantity: 18, dividendsTotal: 0)
]
