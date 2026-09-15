//
//  PlanetCard.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import SwiftUI

struct PlanetCard: View {
    let planet: Planet
    var size: CGFloat = 225

    var body: some View {
        // `image` vient du serveur : déduire l'asset du nom casserait sur
        // « Vénus » et « Terre », dont les fichiers s'appellent venus et earth.
        Image(planet.image)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            // Une planète hors de portée est désaturée et estompée, comme les
            // grades non atteints.
            .grayscale(planet.locked ? 0.9 : 0)
            .opacity(planet.locked ? 0.45 : 1)
            .overlay { if planet.locked { padlock } }
            .accessibilityLabel(
                planet.locked
                ? "\(planet.name), verrouillée. \(planet.energyThreshold) points d'énergie requis."
                : "\(planet.name), atteinte."
            )
    }

    private var padlock: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: size * 0.2, weight: .black))
            .foregroundStyle(.beigeClear)
            .shadow(color: .black.opacity(0.6), radius: 6)
    }
}

#Preview {
    HStack(spacing: 6) {
        PlanetCard(planet: fakePlanets[0], size: 185)
        PlanetCard(planet: fakePlanets.last!, size: 185)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
