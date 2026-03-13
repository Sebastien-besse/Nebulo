//
//  PlanetCard.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import SwiftUI

struct PlanetCard: View {
    let planet: Planet
    var body: some View {
        ZStack{
            Image("earth")
                .resizable()
                .scaledToFit()
                .frame(width: 225, height: 225)
                
        }
    }
}
#Preview {
    PlanetCard(planet: Planet(name: "Uranus", nickname: "", surface: 0, degree: 0, description: "", energyThreshold: 0, locked: false))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.accentColor)
}
