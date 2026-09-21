//
//  Sector.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

/// Un secteur d'activité, tel qu'on le choisit en créant une action.
///
/// `Equatable` est exigé par le carrousel, qui compare les éléments pour
/// savoir lequel est au centre.
struct Sector: Identifiable, Equatable {
    let id: String
    let name: String

    init(_ name: String) {
        self.id = name
        self.name = name
    }
}

/// Le catalogue vit côté client, comme celui des grades : la colonne
/// `actions.secteur` est un `varchar(50)` libre, l'API n'expose aucune liste.
/// La figer ici évite que « Tech », « tech » et « Technologie » cohabitent.
enum SectorCatalog {
    static let all: [Sector] = [
        Sector("Tech"),
        Sector("Santé"),
        Sector("Énergie"),
        Sector("Finance"),
        Sector("Industrie"),
        Sector("Luxe"),
        Sector("Conso"),
        Sector("Immobilier")
    ]
}
