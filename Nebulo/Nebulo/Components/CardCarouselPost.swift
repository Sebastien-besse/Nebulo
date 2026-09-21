//
//  CardCarouselPost.swift
//  Nebulo
//
//  Created by apprenant152 on 16/03/2026.
//

import SwiftUI
import CardCarousel

/// Un message dans le carrousel de l'écran Société : l'auteur, son âge, puis
/// le contenu.
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
                    // dont la hauteur est fixe.
                    .lineLimit(12)
            }
            .font(.system(size: 14))
            .foregroundStyle(.accent)
            .frame(width: 227, alignment: .leading)
            .padding(.leading, 11)
            .padding(.top, 25)
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
