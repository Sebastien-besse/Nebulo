//
//  GradeProgress.swift
//  Nebulo
//
//  Created by apprenant152 on 21/09/2026.
//

import SwiftUI

/// Le grade courant et le chemin vers le suivant : le personnage, son titre,
/// et la barre d'XP.
///
/// L'XP se gagne de trois façons — atteindre une planète, valider un challenge,
/// revenir un jour de plus. C'est ce qui la distingue de l'énergie, qui ne
/// dépend que de l'argent encaissé.
struct GradeProgress: View {
    let grade: UserGrade

    var body: some View {
        HStack(spacing: 14) {
            badgePlate
            VStack(alignment: .leading, spacing: 7) {
                Text(grade.current?.name ?? "Sans grade")
                    .font(.system(size: 20))
                    .fontWeight(.black)
                    .foregroundStyle(.yellowCustom)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                bar

                Text(caption)
                    .font(.system(size: 13))
                    .fontWeight(.black)
                    .foregroundStyle(.beige)
                    .opacity(0.75)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        // Pas de largeur propre : la carte prend celle des champs du profil,
        // sous lesquels elle se range.
        .frame(maxWidth: .infinity)
        .frame(height: 96)
        // Même verre que les cartes du portefeuille : sur le ciel étoilé, une
        // information a besoin d'une surface, sinon elle flotte.
        .glassEffect(
            .clear.tint(Color.white.opacity(0.08)),
            in: .rect(cornerRadius: 18)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            grade.next != nil
            ? "Grade \(grade.current?.name ?? "inconnu"). \(caption)."
            : "Grade \(grade.current?.name ?? "inconnu"), le plus élevé. \(grade.xp) points d'expérience."
        )
    }

    /// Le personnage sur sa plaque violette, comme dans le carrousel du profil :
    /// c'est le traitement du badge partout dans l'application.
    private var badgePlate: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.purpleClear)
            .frame(width: 58, height: 66)
            .overlay {
                if let badge = grade.current {
                    Image(badge.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 51)
                }
            }
    }

    /// La barre se remplit du seuil courant au suivant, et non depuis zéro :
    /// sinon elle semblerait déjà pleine au moment d'une promotion.
    ///
    /// Sa longueur n'est plus fixe : la carte s'étire sur la largeur de l'écran,
    /// la barre suit. D'où le `GeometryReader`, seul moyen de connaître la place
    /// reçue pour y calculer le remplissage.
    private var bar: some View {
        GeometryReader { geometry in
            Capsule()
                .fill(.accent.opacity(0.55))
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(.greenCustom)
                        .frame(width: max(9, geometry.size.width * grade.progressPercent / 100))
                }
                .overlay {
                    Capsule()
                        .strokeBorder(.beigeClear.opacity(0.25), lineWidth: 1)
                }
        }
        .frame(height: 9)
    }

    /// Au sommet il n'y a plus de palier à viser : on montre l'XP seule.
    private var caption: String {
        guard let threshold = grade.nextThreshold else {
            return "\(grade.xp) XP"
        }
        return "\(grade.xp) / \(threshold) XP"
    }
}

#Preview {
    ZStack {
        VStack(spacing: 20) {
            GradeProgress(grade: fakeUserGrade)
            // Au sommet : plus de palier, la barre reste pleine.
            GradeProgress(grade: UserGrade(
                xp: 2150,
                current: GradeCatalog.all.last,
                next: nil,
                progressPercent: 100,
                nextThreshold: nil
            ))
        }
    }
    .padding(.horizontal, 20)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
