//
//  InvestCard.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import SwiftUI

/// Une ligne du portefeuille : le nom de l'action, la quantité détenue et le
/// cumul des dividendes qu'elle a versés.
struct InvestCard: View {
    let action: Action
    /// Toucher la carte ouvre la saisie d'un dividende pour cette action.
    var onOpen: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            nameChip
            cardsData
        }
        // Les cotes viennent de la maquette : le contenu est plaqué en haut à
        // 24, pas centré, ce qui laisse 21 sous les badges.
        .padding(.top, 24)
        .frame(width: 306, height: 171, alignment: .top)
        // Le verre porte lui-même la forme : un `fill` en dessous ferait écran
        // au flou et la carte perdrait ce qui la rend vivante.
        //
        // La teinte est neutre, pas crème. La maquette pose du 250/237/196 à
        // 20 % sur un fond 16/20/33 : une fois composé, cela donne 63/63/66,
        // un gris. Reprendre le crème tel quel le repose au-dessus d'un verre
        // déjà clair, et la carte vire au jaune.
        .glassEffect(
            // `tint` attend un `Color?` : sans le type explicite, le point
            // seul ne retrouve pas la couleur.
            .clear.tint(Color.white.opacity(0.08)),
            in: .rect(cornerRadius: 18)
        )
        .glassEffectTransition(.matchedGeometry)
        .contentShape(Rectangle())
        .onTapGesture { onOpen?() }
    }

    private var nameChip: some View {
        RoundedRectangle(cornerRadius: 9)
            .fill(.accent)
            .frame(width: 139, height: 50)
            .overlay {
                Text(action.name)
                    .font(.system(size: 20))
                    .fontWeight(.black)
                    .foregroundStyle(.beigeClear)
                    // Un nom long ne doit pas élargir la puce : elle a une
                    // largeur fixe dans la maquette.
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 8)
            }
    }

    private var cardsData: some View {
        HStack(spacing: 73) {
            // Le libellé des actions est collé à sa fusée dans la maquette,
            // celui des dividendes est séparé de son billet. Les deux sont
            // repris tels quels.
            cardData(w: 80, title: "🚀Actions",
                     value: "\(action.quantity)", color: .yellowCustom)
            cardData(w: 98, title: "💶 Dividendes",
                     value: action.dividendsTotal.formatted(.number.precision(.fractionLength(0))) + "€",
                     color: .greenCustom)
        }
    }

    /// Les deux lignes occupent 48 des 56 points du badge, plaquées en bas :
    /// la valeur affleure le bord, les 8 points restants sont au-dessus du
    /// libellé. Les hauteurs sont fixées pour que la police du système tombe
    /// aux mêmes cotes que la maquette, dont les blocs font 18 puis 30.
    private func cardData(w: CGFloat, title: String, value: String, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(color)
            .frame(width: w, height: 56)
            .overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    Text(title)
                        .font(.system(size: 14))
                        .frame(height: 18)
                    Text(value)
                        .font(.system(size: 20))
                        .frame(height: 30)
                }
                .fontWeight(.black)
                .foregroundStyle(.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 4)
            }
    }
}

#Preview {
    ZStack {
        // Le conteneur laisse les verres voisins se fondre entre eux quand ils
        // se rapprochent, au lieu de se superposer chacun dans son coin.
        GlassEffectContainer(spacing: 20) {
            VStack(spacing: 20) {
                InvestCard(action: fakeActions[0])
                InvestCard(action: fakeActions[3])
                InvestCard(action: fakeActions.last!)
            }
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
