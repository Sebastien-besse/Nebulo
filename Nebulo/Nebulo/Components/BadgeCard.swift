//
//  BadgeCard.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import SwiftUI

struct BadgeCard: View {
    let badge: Badge
    /// Le grade actuellement porté par l'utilisateur ressort des autres.
    var isCurrent: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.purpleClear)
                .frame(width: 102, height: 106)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.yellowCustom, lineWidth: isCurrent ? 2 : 0)
                }
            VStack(spacing: 4) {
                Image(badge.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45.33, height: 67.99)

                Text(badge.name)
                    .font(.system(size: 14))
                    .fontWeight(.black)
                    .foregroundStyle(isCurrent ? .yellowCustom : .beigeClear)
            }
        }
        .opacity(isCurrent ? 1 : 0.55)
    }
}

#Preview {
    HStack {
        BadgeCard(badge: GradeCatalog.all[0], isCurrent: true)
        BadgeCard(badge: GradeCatalog.all[1])
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
