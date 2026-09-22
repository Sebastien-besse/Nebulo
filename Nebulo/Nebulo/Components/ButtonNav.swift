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
    /// Rond plutôt que carré. C'est la forme des pastilles de l'arc de
    /// navigation, qui naissent d'un hublot : un coin y serait un accident.
    var isRound: Bool = false

    /// Le disque est plus large que le carré de la maquette. Une icône
    /// inscrite dans un cercle n'a pas la même marge qu'inscrite dans un
    /// carré : ses coins tombent à 23,95 points du centre, soit 0,65 de plus
    /// que le rayon de 46,61 — ils mordaient sur le bord. 58 leur rend cinq
    /// points, et dix sur les côtés.
    private var side: CGFloat { isRound ? 58 : 46.61 }

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
                .frame(width: side, height: side)
                // Même verre que les cartes du portefeuille et le bloc de
                // grade : le décor passe à travers au lieu d'être masqué.
                .glassEffect(
                    .clear.tint(Color.white.opacity(0.08)),
                    in: isRound ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: 5))
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
            HStack(spacing: 16) {
                ButtonNav(btnNav: {}, icon: "IconeActions", isRound: true)
                ButtonNav(btnNav: {}, icon: "IconeProfil", isRound: true)
                ButtonNav(btnNav: {}, icon: "IconeForum", isRound: true)
            }
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
