//
//  CardCarouselPost.swift
//  Nebulo
//
//  Created by apprenant152 on 16/03/2026.
//

import SwiftUI
import CardCarousel

/// Un message dans le carrousel de l'écran Société : l'auteur, son âge, le
/// contenu, et le nombre de réponses qu'il a reçues.
struct CardCarouselPost: View {
    let post: Post

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(.orangeCustom)
                .frame(width: 251, height: 321)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(post.authorFirstname), \(post.authorAge) ans")
                    .fontWeight(.black)
                Text(post.content)
                    .fontWeight(.medium)
                    .lineHeight(.leading(increase: 6))
                    // Le bloc de texte fait 252 points dans la maquette, soit
                    // douze lignes. Au-delà, le message déborderait de la carte,
                    // dont la hauteur est fixe. La dernière est rendue au
                    // décompte, posé en pied.
                    .lineLimit(11)
            }
            .font(.system(size: 14))
            .foregroundStyle(.accent)
            .frame(width: 227, alignment: .leading)
            .padding(.leading, 11)
            .padding(.top, 25)
        }
        .overlay(alignment: .bottomLeading) {
            responseBadge
                .padding(.leading, 11)
                .padding(.bottom, 14)
        }
    }

    /// Le pied de carte : hors maquette, mais sans lui rien ne dit que la
    /// carte s'ouvre, et le fil de réponses resterait invisible.
    private var responseBadge: some View {
        HStack(spacing: 5) {
            Text(label)
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .black))
        }
        .font(.system(size: 13))
        .fontWeight(.black)
        .foregroundStyle(.accent.opacity(0.65))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label). Ouvrir le fil.")
    }

    /// Le pluriel se décide ici : « 1 réponses » se remarque plus qu'un fil
    /// vide.
    private var label: String {
        switch post.responseCount {
        case 0:  return "Répondre"
        case 1:  return "1 réponse"
        default: return "\(post.responseCount) réponses"
        }
    }
}

#Preview {
    ZStack {
        CardCarouselPost(post: fakePosts[0])
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
