//
//  ButtonNav.swift
//  Nebulo
//
//  Created by apprenant152 on 16/03/2026.
//

import SwiftUI

struct ButtonNav: View {
    var btnNav : ()->Void
    var icon: String

    var body: some View {
        Button(action: btnNav) {
            Image(icon)
                // Les trois icônes sont d'une seule teinte, #23203F, dessinées
                // pour le fond crème d'origine. Le rendu `template` les
                // reteinte en crème sans toucher aux assets : la forme vient de
                // l'alpha, la couleur du code. Sans cela, du sombre sur du
                // verre sombre.
                .renderingMode(.template)
                .resizable()
                .scaledToFill()
                .frame(width: 36.25, height: 31.32)
                .foregroundStyle(.beigeClear)
                .frame(width: 46.61, height: 46.61)
                // Même verre que les cartes du portefeuille et le bloc de
                // grade : le décor passe à travers au lieu d'être masqué.
                .glassEffect(
                    .clear.tint(Color.white.opacity(0.08)),
                    in: .rect(cornerRadius: 5)
                )
        }
    }
}

#Preview {
    ZStack {
        VStack(spacing: 16) {
            HStack {
                ButtonNav(btnNav: {}, icon: "IconeActions")
                Spacer()
                ButtonNav(btnNav: {}, icon: "IconeProfil")
            }
            ButtonNav(btnNav: {}, icon: "IconeForum")
        }
        .padding(40)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background {
        Image("BackgroundHome")
            .resizable()
            .scaledToFill()
    }
    .background(Color.accentColor)
}
