//
//  HeaderBar.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import SwiftUI

/// L'en-tête commun à tous les écrans : le retour à gauche, le titre au
/// centre, et un bouton d'action facultatif à droite.
///
/// Chaque écran masque la barre système et dessine son propre en-tête,
/// conformément aux maquettes. Le retour est porté ici plutôt que par
/// l'appelant : il dépile toujours, et aucun écran n'a eu besoin d'autre chose.
struct HeaderBar: View {
    let title: String
    /// Nom de l'asset du bouton de droite. Nil sur les écrans qui n'en ont
    /// pas — Profil, Forum et Société n'en portent aucun dans la maquette.
    var trailingIcon: String? = nil
    var trailingAction: () -> Void = {}

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image("IconBack")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 54, height: 30)
                }
                Spacer()
                if let trailingIcon {
                    trailingButton(icon: trailingIcon)
                }
            }
            // Le titre est centré sur l'écran, pas sur l'espace laissé par les
            // boutons : il ne doit pas se déplacer selon qu'il y en a un ou non.
            TitleCard(title: title)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    /// Le rond crème est dessiné ici : l'asset ne porte que le signe, ce qui
    /// permet de le réutiliser ailleurs sans son fond.
    private func trailingButton(icon: String) -> some View {
        Button(action: trailingAction) {
            Circle()
                .fill(.beigeClear)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
        }
    }
}

#Preview {
    ZStack {
        VStack(spacing: 60) {
            HeaderBar(title: "Portefeuille", trailingIcon: "IconePlus") {
                print("Ajouter une action")
            }
            HeaderBar(title: "Profil")
            Spacer()
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
