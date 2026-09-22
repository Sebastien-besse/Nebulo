//
//  BadgeCard.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import SwiftUI

struct BadgeCard: View {
    let badge: Badge
    /// Le grade actuellement porté par l'utilisateur ressort des autres.
    var isCurrent: Bool = false
    /// Un grade pas encore atteint. Son personnage et son nom sont floutés :
    /// on voit qu'il reste du chemin, sans savoir ce qui attend au bout.
    var isLocked: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.purpleClear)
                .frame(width: 102, height: 106)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.yellowCustom, lineWidth: isCurrent ? 2 : 0)
                }
            VStack(spacing: 4) {
                Image(badge.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45.33, height: 67.99)

                Text(badge.name)
                    .font(.system(size: 14))
                    .fontWeight(.black)
                    .foregroundStyle(isCurrent ? .yellowCustom : .beigeClear)
            }
            // Le flou porte sur le personnage et sur le nom : ni l'un ni
            // l'autre ne doit se lire tant que le grade n'est pas atteint.
            .grayscale(isLocked ? 0.9 : 0)
            .blur(radius: isLocked ? 6 : 0)

            // Hors du flou, sinon le cadenas s'effacerait avec le reste.
            if isLocked { padlock }
        }
        .opacity(isCurrent ? 1 : 0.55)
        .accessibilityElement(children: .ignore)
        // Le nom n'est pas dit non plus : le lecteur d'écran n'a pas à révéler
        // ce que l'écran cache.
        .accessibilityLabel(
            isLocked
            ? "Grade verrouillé."
            : (isCurrent ? "\(badge.name), grade actuel." : "\(badge.name), atteint.")
        )
    }

    private var padlock: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 26, weight: .black))
            .foregroundStyle(.beigeClear)
            .shadow(color: .black.opacity(0.6), radius: 6)
    }
}

#Preview {
    HStack {
        BadgeCard(badge: GradeCatalog.all[0])
        BadgeCard(badge: GradeCatalog.all[1], isCurrent: true)
        BadgeCard(badge: GradeCatalog.all[2], isLocked: true)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
