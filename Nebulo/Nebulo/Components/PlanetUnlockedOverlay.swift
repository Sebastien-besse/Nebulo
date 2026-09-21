//
//  PlanetUnlockedOverlay.swift
//  Nebulo
//
//  Created by apprenant152 on 21/09/2026.
//

import SwiftUI

/// La célébration d'un seuil franchi : la planète surgit, nommée, une fois
/// seulement — au premier rechargement qui la découvre atteinte.
///
/// C'est le moment où la gamification paie. Tout le reste de l'application ne
/// fait que rapprocher l'utilisateur de cet écran.
struct PlanetUnlockedOverlay: View {
    let planet: Planet
    let onDismiss: () -> Void

    /// Passe à vrai juste après l'apparition : c'est ce changement qui joue
    /// l'arrivée de la planète, et non son simple affichage.
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Le décor de l'accueil reste deviné derrière, sans distraire.
            Color.accentColor
                .opacity(0.94)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Text("Planète débloquée")
                    .font(.system(size: 20))
                    .fontWeight(.black)
                    .foregroundStyle(.yellowCustom)

                globe

                nameChip

                Text("Seuil de \(planet.energyThreshold) points d'énergie franchi.")
                    .font(.system(size: 16))
                    .foregroundStyle(.beige)
                    .opacity(0.8)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                ButtonAction(name: "Continuer", action: onDismiss)
                    .padding(.top, 10)
            }
            .opacity(appeared ? 1 : 0)
        }
        .animation(
            reduceMotion ? nil : .spring(response: 0.75, dampingFraction: 0.6),
            value: appeared
        )
        .onAppear { appeared = true }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(planet.name) débloquée.")
    }

    /// La planète grandit depuis presque rien, avec un halo qui se déploie
    /// derrière elle. Le ressort du `spring` lui donne son rebond.
    private var globe: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.yellowCustom.opacity(0.35), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 170
                    )
                )
                .frame(width: 340, height: 340)
                .scaleEffect(appeared ? 1 : 0.2)
                .opacity(appeared ? 1 : 0)

            Image(planet.image)
                .resizable()
                .scaledToFit()
                .frame(width: 230, height: 230)
                .scaleEffect(appeared ? 1 : 0.25)
                .rotationEffect(.degrees(appeared ? 0 : -45))
        }
    }

    /// Le nom s'affiche en clair : c'est précisément ce que le flou de la
    /// fiche cachait tant que la planète était hors de portée.
    private var nameChip: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(.beigeClear)
            .frame(width: 197, height: 66)
            .overlay {
                Text(planet.name)
                    .font(.system(size: 32))
                    .fontWeight(.black)
                    .foregroundStyle(.accent.opacity(0.62))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 10)
            }
    }
}

#Preview {
    PlanetUnlockedOverlay(planet: fakePlanets[1]) {}
}
