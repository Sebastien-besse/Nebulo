//
//  BadgeCard.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import SwiftUI

struct BadgeCard: View {
    let badge: Badge
    var body: some View {
        HStack{
            ZStack{
                RoundedRectangle(cornerRadius: 14)
                    .fill(.purpleClear)
                    .frame(width: 102, height: 106)
                VStack{
                    Image("navigateur")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45.33, height: 67.99)
                    
                    Text("Astro")
                        .font(.system(size: 14))
                        .fontWeight(.black)
                        .foregroundStyle(.beigeClear)
                }

            }
        }
    }
}

#Preview {
    BadgeCard(badge: Badge(
        image: "BadgeAstro",
        name: "Astro",
        description: "")
    )
}
