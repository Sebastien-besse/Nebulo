//
//  CorporateCard.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import SwiftUI

/// Une ligne du forum : l'entreprise dont parle le message, sa date, et les
/// deux votes chaud et froid.
struct CorporateCard: View {
    let post: Post
    /// Faux sur ses propres messages : l'API refuse qu'on s'auto-vote.
    var canVote: Bool = true
    var onVote: (VoteType) -> Void = { _ in }
    /// Toucher la carte ouvre l'entreprise. Inerte sur un message qui n'en
    /// vise aucune : il n'y a alors rien à ouvrir.
    var onOpen: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 30) {
            HStack(alignment: .bottom) {
                Spacer()
                dateBadge
            }
            .frame(width: 320)
            .padding(.top, 10)

            nameChip
            cardData()
        }
        .frame(width: 342, height: 212)
        // Le verre porte lui-même la forme, comme sur les cartes du
        // portefeuille : un `fill` en dessous ferait écran au flou. La teinte
        // est neutre — reprendre le crème de la maquette par-dessus un verre
        // déjà clair ferait virer la carte au jaune.
        .glassEffect(
            .clear.tint(Color.white.opacity(0.08)),
            in: .rect(cornerRadius: 12)
        )
        .glassEffectTransition(.matchedGeometry)
        // Les boutons de vote gardent la priorité : ils captent leur propre
        // toucher avant que celui-ci n'atteigne la carte.
        .contentShape(Rectangle())
        .onTapGesture { onOpen?() }
    }

    /// La pastille épouse sa date au lieu de l'inverse.
    ///
    /// Le node fixe 91 points de large, avec 11 de marge de chaque côté. Cette
    /// cote est calibrée pour du Poppins ; la police du système est plus large
    /// à taille égale, et « 17 juin 2025 » débordait. Les 91 deviennent donc un
    /// plancher, pas une contrainte.
    private var dateBadge: some View {
        Text(post.dateOfCreated.forumBadge)
            .font(.system(size: 14))
            .fontWeight(.black)
            .foregroundStyle(.accent)
            .lineLimit(1)
            .padding(.horizontal, 11)
            .frame(minWidth: 91, minHeight: 30)
            .background {
                RoundedRectangle(cornerRadius: 7)
                    .fill(.orangeCustom)
            }
    }

    private var nameChip: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(.accent)
            .frame(width: 204, height: 70.15)
            .overlay {
                // Un message peut ne viser aucune entreprise : la clé est
                // facultative côté API, et le SET NULL la vide si la société
                // disparaît.
                Text(post.companyName ?? "Général")
                    .font(.system(size: 32))
                    .fontWeight(.black)
                    .foregroundStyle(.beigeClear)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 10)
            }
    }

    /// La pilule de vote : le chaud, la température, le froid.
    ///
    /// Cotes du node : capsule de 174 sur 53, deux cercles de 49 centrés à
    /// 30,5 et 142,5. Restent 63 points au milieu, que la maquette laisse vides
    /// — c'est la place du degré, dont la valeur ne peut pas y être dessinée.
    func cardData() -> some View {
        ZStack {
            Capsule()
                .fill(.orangeCustom)
                .frame(width: 174, height: 53)
            HStack(spacing: 0) {
                circleVote(icon: "fire", value: .hot)
                Spacer(minLength: 0)
                temperature
                Spacer(minLength: 0)
                circleVote(icon: "cold", value: .cold)
            }
            // 174 moins les 6 points de marge de chaque côté.
            .frame(width: 162)
            .fontWeight(.black)
            .foregroundStyle(.accent)
        }
        .padding(.top, -10)
    }

    /// Les votes chauds moins les froids. Le signe négatif se lit de lui-même,
    /// le positif n'a pas besoin d'être annoncé — comme sur Dealabs.
    private var temperature: some View {
        Text("\(post.temperature)°")
            .font(.system(size: 20))
            .fontWeight(.black)
            .foregroundStyle(.accent)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .accessibilityLabel("Température : \(post.temperature) degrés.")
    }

    /// Le vote posé ne s'entoure de rien : c'est **l'autre** qui recule.
    ///
    /// Un liseré aurait ajouté une couleur de plus sur une pilule qui en porte
    /// déjà trois. Et remplir le cercle choisi ne marche pas non plus : la
    /// flamme est du même orange que la pilule, le flocon du même crème que le
    /// reste — l'un des deux glyphes disparaîtrait.
    ///
    /// Tant qu'on n'a pas voté, les deux sont à égalité. Le choix fait, le
    /// retenu garde sa taille et l'écarté s'efface : la différence se lit d'un
    /// coup d'œil sans qu'on ait rien dessiné de neuf.
    func circleVote(icon: String, value: VoteType) -> some View {
        let chosen = post.myVote == value
        let setAside = post.myVote != nil && !chosen

        return Button {
            onVote(value)
        } label: {
            ZStack {
                Circle()
                    .fill(.accent)
                    .frame(width: 49)
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32)
            }
            .scaleEffect(setAside ? 0.84 : 1)
            .opacity(setAside ? 0.4 : 1)
        }
        // Le ressort rend le vote sensible sous le doigt : les deux cercles
        // s'échangent la vedette au lieu de changer d'état sèchement.
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: post.myVote)
        .accessibilityLabel(value == .hot ? "Chaud" : "Froid")
        .accessibilityAddTraits(chosen ? .isSelected : [])
        // Éteindre les boutons plutôt que de laisser partir une requête que le
        // serveur refusera. La température, elle, reste lisible : c'est une
        // information, pas une commande.
        .opacity(canVote ? 1 : 0.5)
        .disabled(!canVote)
    }
}

#Preview {
    ZStack {
        VStack(spacing: 34) {
            CorporateCard(post: fakePosts[0])
            CorporateCard(post: fakePosts[1])
            // Son propre message : les votes sont éteints.
            CorporateCard(post: fakePosts.last!, canVote: false)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
