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
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(.beigeClear.opacity(0.2))
                .frame(width: 342, height: 212)
                .glassEffectTransition(GlassEffectTransition.matchedGeometry)
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
        }
        // Les boutons de vote gardent la priorité : ils captent leur propre
        // toucher avant que celui-ci n'atteigne la carte.
        .contentShape(Rectangle())
        .onTapGesture { onOpen?() }
    }

    private var dateBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(.orangeCustom)
                .frame(width: 91, height: 30)
            Text(post.dateOfCreated.forumBadge)
                .font(.system(size: 14))
                .fontWeight(.black)
                .foregroundStyle(.accent)
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

    func cardData() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(.orangeCustom)
                .frame(width: 158, height: 52.62)
            HStack(spacing: 48) {
                circleVote(icon: "fire", value: .hot)
                circleVote(icon: "cold", value: .cold)
            }
            .fontWeight(.black)
            .foregroundStyle(.accent)
        }
        .padding(.top, -10)
        // Éteindre les boutons plutôt que de laisser partir une requête que
        // le serveur refusera.
        .opacity(canVote ? 1 : 0.5)
        .disabled(!canVote)
    }

    /// Le vote déjà posé se signale par un liseré jaune, comme le grade
    /// courant dans `BadgeCard` — la maquette ne prévoit pas cet état.
    func circleVote(icon: String, value: VoteType) -> some View {
        Button {
            onVote(value)
        } label: {
            ZStack {
                Circle()
                    .fill(.accent)
                    .frame(width: 49)
                    .overlay {
                        Circle()
                            .strokeBorder(.yellowCustom, lineWidth: post.myVote == value ? 2 : 0)
                    }
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32)
            }
        }
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
