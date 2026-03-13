//
//  Planet.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import Foundation

struct Planet: Identifiable{
    let id = UUID()
    let name: String
    let nickname: String
    let surface: Int
    let degree: Int
    let description: String
    let energyThreshold: Int
    let locked: Bool
}
