//
//  PlanetDetailView.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import SwiftUI

/// La galaxie, feuilletable d'une planète à l'autre.
///
/// L'écran s'ouvre sur celle qu'on a touchée, et le balayage latéral parcourt
/// les huit dans l'ordre des distances : ce qui est atteint, ce qui vient
/// ensuite, et ce qu'il reste après.
struct PlanetDetailView: View {
    /// Triées par seuil croissant : c'est l'ordre du voyage.
    private let planets: [Planet]
    /// Énergie accumulée, pour dire ce qu'il manque plutôt qu'un seuil brut.
    private let energy: Int

    @State private var selection: UUID

    /// Les planètes arrivent déjà chargées de l'écran appelant : celui-ci ne
    /// lit rien au serveur, d'où l'absence de ViewModel.
    init(planets: [Planet], selected: Planet, energy: Int) {
        self.planets = planets.sorted { $0.energyThreshold < $1.energyThreshold }
        self.energy = energy
        _selection = State(initialValue: selected.id)
    }

    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()
            starfield

            VStack(spacing: 0) {
                // Pas de titre : la maquette porte le nom de la planète dans
                // une pastille sous l'en-tête, pas dans la barre.
                HeaderBar(title: "")
                TabView(selection: $selection) {
                    ForEach(planets) { planet in
                        page(for: planet)
                            .tag(planet.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                // Pagination dessinée à la main : celle du système se pose au
                // ras du contenu, trop haut, et dans ses propres couleurs.
                pageDots
                    .padding(.bottom, 14)
            }
        }
        // L'écran a son propre bouton retour, dessiné dans l'en-tête.
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: Une planète

    private func page(for planet: Planet) -> some View {
        VStack(spacing: 0) {
            nameChip(for: planet)
                .padding(.top, 16)
            PlanetDetail(planet: planet)
                .padding(.top, 40)
            Spacer(minLength: 0)
            threshold(for: planet)
                .padding(.bottom, 12)
        }
    }

    // MARK: Décor

    /// Champ d'étoiles propre à cet écran, centré comme dans la maquette.
    private var starfield: some View {
        Image("BackgroundPlanetDetail")
            .resizable()
            .scaledToFill()
            .frame(width: 334, height: 675)
            .allowsHitTesting(false)
    }

    // MARK: Nom

    /// Même pastille que sur l'écran Société, mais le texte y est gris foncé
    /// plutôt que bleu : 62 % du fond de l'application.
    ///
    /// Le nom d'une planète hors de portée est flouté : apprendre où l'on va
    /// fait partie de la récompense. On voit qu'il y a un mot, pas lequel.
    private func nameChip(for planet: Planet) -> some View {
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
                    .blur(radius: planet.locked ? 9 : 0)
            }
            // Le flou déborde de la pastille s'il n'est pas rogné.
            .clipShape(RoundedRectangle(cornerRadius: 7))
            // Sans quoi VoiceOver lirait le nom que le flou cache.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(planet.locked ? "Planète inconnue" : planet.name)
    }

    /// Un point par planète, le point courant en jaune.
    private var pageDots: some View {
        HStack(spacing: 7) {
            ForEach(planets) { planet in
                Circle()
                    .fill(planet.id == selection ? Color.yellowCustom : Color.beigeClear.opacity(0.3))
                    .frame(width: 7, height: 7)
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: Seuil

    /// Sur une planète hors de portée, ce qu'il reste à accumuler plutôt que le
    /// seuil brut : « il te manque 487 » se lit sans soustraction mentale.
    private func threshold(for planet: Planet) -> some View {
        let missing = max(0, planet.energyThreshold - energy)

        return VStack(spacing: 8) {
            Text(planet.locked ? "énergie manquante" : "seuil franchi")
                .font(.system(size: 14))
                .fontWeight(.black)
                .foregroundStyle(.yellowCustom)

            RoundedRectangle(cornerRadius: 12)
                .fill(.orangeCustom)
                .frame(width: 243, height: 66.96)
                .overlay {
                    Text((planet.locked ? missing : planet.energyThreshold).formatted())
                        .font(.system(size: 36))
                        .fontWeight(.black)
                        .foregroundStyle(.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 12)
                }
        }
        .accessibilityElement(children: .ignore)
        // Le nom est tu tant que la planète est verrouillée : l'annoncer ici
        // reviendrait à défaire le flou de la pastille.
        .accessibilityLabel(
            planet.locked
            ? "Planète verrouillée. Il te manque \(missing) points d'énergie."
            : "\(planet.name) atteinte. Seuil : \(planet.energyThreshold) points d'énergie."
        )
    }
}

#Preview {
    // Présenté en `fullScreenCover`, donc hors de toute pile : le bouton de
    // l'en-tête referme la présentation via `dismiss`.
    //
    // Le jeu d'exemple a la Terre et Mercure atteintes, les six autres hors de
    // portée : on ouvre sur Mercure pour voir les deux états en balayant.
    PlanetDetailView(planets: fakePlanets, selected: fakePlanets[1], energy: 80)
}
