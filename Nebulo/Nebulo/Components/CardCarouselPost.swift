//
//  CardCarouselPost.swift
//  Nebulo
//
//  Created by apprenant152 on 16/03/2026.
//

import SwiftUI
import CardCarousel

struct CardCarouselPost: View {
    let post : Post
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 18)
                .fill(.orangeCustom)
                .frame(width: 251, height: 328)
            VStack(alignment: .leading, spacing: 10){
                Text("\(post.nameUser), \(post.yearUser)")
                    
                    .fontWeight(.black)
                Text(post.content)
                    .lineHeight(.leading(increase: 6))
            }
            .font(.system(size: 14))
            .frame(width: 220)
        }

    }
}

#Preview {
    CardCarouselPost(post: fakePosts[0])
}
