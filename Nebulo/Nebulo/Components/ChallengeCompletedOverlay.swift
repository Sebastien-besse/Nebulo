//
//  ChallengeCompletedOverlay.swift
//  Nebulo
//
//  Created by apprenant152 on 23/09/2026.
//

import SwiftUI

/// La célébration d'un challenge validé : l'objectif atteint est rappelé, et
/// l'énergie qu'il rapporte est annoncée.
///
/// Troisième voile de l'application, après ceux des planètes et des grades.
/// Les trois se ressemblent volontairement : même teinte, même rythme, même
/// bouton. Celui-ci vient en premier quand plusieurs tombent ensemble — c'est
/// le challenge qui crédite l'énergie, donc lui qui a débloqué le reste.
struct ChallengeCompletedOverlay: View {
    let challenge: Challenge
    /// Y a-t-il un challenge derrière celui-là ? Le pool est fini : une fois
    /// le dernier validé, il n'y a plus rien à tirer, et l'écran le dit
    /// plutôt que de promettre une suite qui ne viendra pas.
    let hasNextChallenge: Bool
    let onDismiss: () -> Void

    /// Passe à vrai juste après l'apparition : c'est ce changement qui joue
    /// l'arrivée du sceau, et non son simple affichage.
    @State private var appeared = false
    /// L'énergie gagnée monte une fraction de seconde après le reste. Elle
    /// arrive donc comme une conséquence, pas comme une ligne de plus.
    @State private var rewardShown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Le voile tombe sur un accueil intact — rien n'est parti, comme
            // pour la promotion. Sans le flou, le montant et le challenge se
            // liraient encore derrière le titre.
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            Color.accentColor
                .opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                VStack(spacing: 6) {
                    Text("Challenge validé !")
                        .font(.system(size: 24))
                        .fontWeight(.black)
                        .foregroundStyle(.yellowCustom)

                    Text("Objectif atteint.")
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .foregroundStyle(.beige)
                        .opacity(0.9)
                }

                seal

                // Ce qui vient d'être accompli, dans les mots mêmes de la
                // carte de l'accueil : on reconnaît la ligne qu'on regardait
                // depuis des jours.
                descriptionChip

                reward

                Text(encouragement)
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
        .animation(
            reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.7),
            value: rewardShown
        )
        .onAppear {
            appeared = true
            guard !reduceMotion else {
                rewardShown = true
                return
            }
            Task {
                try? await Task.sleep(for: .milliseconds(260))
                rewardShown = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            "Challenge validé. \(challenge.description). "
            + "Plus \(challenge.energyReward) points d'énergie. \(encouragement)"
        )
    }

    /// Ce qui relance, plutôt que ce qui reste à faire.
    private var encouragement: String {
        hasNextChallenge
            ? "Un nouveau challenge t’attend déjà sur l’accueil."
            : "Tu les as tous relevés. Il n’en reste aucun à tirer."
    }

    /// Le sceau : une coche dans un disque, sous un halo. Pas d'image à
    /// afficher — un challenge n'a pas de visage, contrairement à une planète
    /// ou à un grade —, alors c'est la validation elle-même qu'on montre.
    private var seal: some View {
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

            // Le même disque sombre que la médaille des grades : les deux
            // récompenses se posent sur le même support.
            Circle()
                .fill(Color.black.opacity(0.28))
                .frame(width: 200, height: 200)
                .overlay {
                    Circle()
                        .strokeBorder(Color.beige.opacity(0.22), lineWidth: 1)
                }
                .scaleEffect(appeared ? 1 : 0.2)

            Image(systemName: "checkmark")
                .font(.system(size: 92, weight: .black))
                .foregroundStyle(.yellowCustom)
                .scaleEffect(appeared ? 1 : 0.25)
                .rotationEffect(.degrees(appeared ? 0 : -45))
        }
        .frame(height: 340)
    }

    /// L'énoncé du challenge, dans la plaque des planètes et des grades. Il est
    /// plus long qu'un nom propre : la plaque s'élargit et le texte peut aller
    /// sur deux lignes.
    private var descriptionChip: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(.beigeClear)
            .frame(width: 280, height: 66)
            .overlay {
                Text(challenge.description)
                    .font(.system(size: 18))
                    .fontWeight(.black)
                    .foregroundStyle(.accent.opacity(0.62))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 12)
            }
    }

    /// L'énergie créditée. C'est la monnaie qui rapproche de la planète
    /// suivante : elle mérite d'être lue, pas devinée d'un total qui a bougé.
    private var reward: some View {
        HStack(spacing: 8) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 20, weight: .bold))
            Text("+\(challenge.energyReward) points d’énergie")
                .font(.system(size: 20))
                .fontWeight(.black)
        }
        .foregroundStyle(.yellowCustom)
        .scaleEffect(rewardShown ? 1 : 0.6)
        .opacity(rewardShown ? 1 : 0)
    }
}

#Preview {
    ChallengeCompletedOverlay(challenge: fakeChallenge, hasNextChallenge: true) {}
}
