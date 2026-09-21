//
//  PlanetDetail.swift
//  Nebulo
//
//  Created by apprenant152 on 20/03/2026.
//

import SwiftUI

/// La planète et ses quatre étiquettes : surnom, température, diamètre et
/// description.
///
/// Le titre n'est plus porté ici : la maquette le place dans une pastille
/// crème au-dessus, que l'écran dessine lui-même. Ce composant se limite donc
/// à l'illustration.
///
/// Une planète hors de portée ne montre que son globe, désaturé et cadenassé :
/// le surnom, la température, le diamètre et la description sont ce qu'on gagne
/// en y arrivant.
struct PlanetDetail: View {
    let planet: Planet

    var body: some View {
        planetContent
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
            // Le cadre porte les quatre encadrés et les traits qui les relient
            // à la planète : sans étiquettes à relier, il n'a rien à dessiner.
            if !planet.locked {
                Image("cadre")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 373, height: 404)
            }
            // Même traitement que les cartes du profil : désaturée et estompée,
            // la planète reste reconnaissable sans paraître accessible.
            Image(planet.image)
                .resizable()
                .scaledToFill()
                .frame(width: 436, height: 436)
                .grayscale(planet.locked ? 0.9 : 0)
                .opacity(planet.locked ? 0.45 : 1)
                .offset(x: 10, y: -30)

            if planet.locked {
                padlock
            } else {
                planetData(x: -126, y: -184, content: planet.nickname)
                planetData(x: 70, y: 150, content: planet.description)
                planetData(x: 128, y: -112, content: "\(String(planet.temperature))°C")
                planetData(x: -143, y: 34, content: "\(String(planet.surface)) KM")
            }
        }
        // Le cadre n'est plus là pour donner sa taille quand la planète est
        // verrouillée : la fixer évite que la page saute d'une planète à
        // l'autre pendant le balayage.
        .frame(width: 373, height: 404)
    }

    /// Posé au centre du globe, donc décalé comme lui.
    private var padlock: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 72, weight: .black))
            .foregroundStyle(.beigeClear)
            .shadow(color: .black.opacity(0.6), radius: 10)
            .offset(x: 10, y: -30)
    }
}

#Preview {
    ZStack {
        HStack(spacing: 0) {
            PlanetDetail(planet: fakePlanets[0])
            PlanetDetail(planet: fakePlanets.last!)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
