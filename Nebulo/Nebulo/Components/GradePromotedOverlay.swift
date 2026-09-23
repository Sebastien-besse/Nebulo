//
//  GradePromotedOverlay.swift
//  Nebulo
//
//  Created by apprenant152 on 23/09/2026.
//

import SwiftUI

/// La célébration d'un grade gagné : le badge surgit dans une gerbe d'étoiles,
/// nommé, une fois seulement — au premier rechargement qui découvre la montée.
///
/// C'est le pendant de `PlanetUnlockedOverlay` pour la seconde progression de
/// l'application. Les deux se ressemblent volontairement : même voile, même
/// rythme, même bouton. L'utilisateur reconnaît qu'il vient de franchir
/// quelque chose avant même d'avoir lu ce que c'est.
struct GradePromotedOverlay: View {
    let badge: Badge
    /// Y a-t-il un palier au-dessus ? Seulement cela : ni son nom ni son seuil.
    /// Les annoncer ici déflorait la prochaine promotion, alors que la
    /// surprise est précisément ce qui donne son prix à cet écran. Le profil
    /// les montre à qui va les chercher.
    let hasNextGrade: Bool
    let onDismiss: () -> Void

    /// Passe à vrai juste après l'apparition : c'est ce changement qui joue
    /// l'arrivée du badge, et non son simple affichage.
    @State private var appeared = false
    /// La gerbe part une fraction de seconde après le badge. Ensemble, les
    /// deux se liraient comme un seul bloc qui grossit.
    @State private var burst = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Le nombre de branches de la gerbe. Douze : assez pour faire le tour
    /// sans que l'œil puisse les compter.
    private static let rayCount = 12

    var body: some View {
        ZStack {
            // Le décor de l'accueil reste deviné derrière, sans distraire.
            //
            // Il est d'abord flouté, puis teinté. Le voile des planètes se
            // contente d'un aplat translucide, mais celui-là tombe sur un ciel
            // vide — le vaisseau est parti. La promotion, elle, recouvre un
            // accueil intact : sans le flou, le montant et le challenge se
            // lisaient encore derrière le titre.
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            Color.accentColor
                .opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                // L'écran félicite avant de nommer : c'est une récompense,
                // pas une notification d'état.
                VStack(spacing: 6) {
                    Text("Félicitations !")
                        .font(.system(size: 24))
                        .fontWeight(.black)
                        .foregroundStyle(.yellowCustom)

                    Text("Tu as pris du galon.")
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .foregroundStyle(.beige)
                        .opacity(0.9)
                }

                // Le nom passe avant l'image : on lit le grade obtenu, puis on
                // voit à quoi il ressemble. L'inverse faisait chercher la
                // légende sous une image qu'on ne savait pas encore nommer.
                nameChip

                medal

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
            reduceMotion ? nil : .easeOut(duration: 0.9),
            value: burst
        )
        .onAppear {
            appeared = true
            guard !reduceMotion else { return }
            Task {
                try? await Task.sleep(for: .milliseconds(120))
                burst = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            "Félicitations, tu as pris du galon. Nouveau grade : "
            + "\(badge.name). \(encouragement)"
        )
    }

    /// Ce qui relance, plutôt que ce qui reste à faire. La ligne pousse à
    /// repartir sans nommer la marche suivante.
    private var encouragement: String {
        hasNextGrade
            ? "Continue sur ta lancée, un autre galon t’attend là-haut."
            : "Plus rien au-dessus de toi. Tu es au sommet de la flotte."
    }

    /// Le badge grandit depuis presque rien, avec un halo derrière lui et une
    /// gerbe qui s'ouvre au même instant. Le ressort du `spring` lui donne son
    /// rebond ; les rais, eux, s'éteignent en s'éloignant.
    private var medal: some View {
        ZStack {
            rays

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

            // Le disque sombre rappelle le hublot, où ce badge vient de
            // prendre la place du précédent.
            Circle()
                .fill(Color.black.opacity(0.28))
                .frame(width: 200, height: 200)
                .overlay {
                    Circle()
                        .strokeBorder(Color.beige.opacity(0.22), lineWidth: 1)
                }
                .scaleEffect(appeared ? 1 : 0.2)

            Image(badge.image)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .scaleEffect(appeared ? 1 : 0.25)
                .rotationEffect(.degrees(appeared ? 0 : -45))
        }
        .frame(height: 340)
    }

    /// Douze rais qui s'écartent du centre en s'effaçant. Ils ne tournent pas :
    /// une gerbe qui pivote se lit comme un chargement, pas comme un éclat.
    private var rays: some View {
        ZStack {
            ForEach(0..<Self.rayCount, id: \.self) { index in
                Capsule()
                    .fill(.yellowCustom)
                    .frame(width: 4, height: 26)
                    .offset(y: burst ? -150 : -70)
                    .rotationEffect(
                        .degrees(Double(index) / Double(Self.rayCount) * 360)
                    )
                    .opacity(burst ? 0 : 0.9)
            }
        }
        .allowsHitTesting(false)
    }

    /// Le nom du grade, dans la même plaque que celle des planètes.
    private var nameChip: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(.beigeClear)
            .frame(width: 197, height: 66)
            .overlay {
                Text(badge.name)
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
    GradePromotedOverlay(badge: GradeCatalog.all[4], hasNextGrade: true) {}
}
