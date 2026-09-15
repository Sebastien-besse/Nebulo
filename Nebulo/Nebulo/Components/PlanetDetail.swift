//
//  PlanetDetail.swift
//  Nebulo
//
//  Created by apprenant152 on 20/03/2026.
//

import SwiftUI

struct PlanetDetail: View {
    let planet: Planet
    var body: some View {
        VStack(spacing: 100){
                TitleCard(title: planet.name)
                planetContent
            
            }
        
    }
    
    @ViewBuilder
    func planetData(x: CGFloat, y: CGFloat, content: String) -> some View{
        Text("\(content)")
            .font(.system(size: 14))
            .fontWeight(.black)
            .foregroundStyle(.white)
            .frame(width: 220)
            .offset(x: x, y: y)
    }
    
    var planetContent: some View {
        ZStack{
            Image("cadre")
                .resizable()
                .scaledToFill()
                .frame(width: 373, height: 404)
            Image(planet.image)
                .resizable()
                .scaledToFill()
                .frame(width: 436, height: 436)
                .offset(x: 10, y: -30)
            planetData(x: -126, y: -184, content: planet.nickname)
            planetData(x: 70, y: 150, content: planet.description)
            planetData(x: 128, y: -112, content: "\(String(planet.temperature))°C")
            planetData(x: -143, y: 34, content: "\(String(planet.surface)) KM")
        }
    }
}

#Preview {
    PlanetDetail(planet: Planet(
        id: UUID(), image: "uranus", name: "Uranus", nickname: "La géante de glace",
        surface: 50724, temperature: -224,
        description: "Elle tourne presque couchée sur le côté, créant des saisons extrêmes. Un monde froid, mystérieux et fascinant.",
        energyThreshold: 2871, locked: false, unlockedAt: .now))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.accentColor)
}
