//
//  TitleCard.swift
//  Nebulo
//
//  Created by apprenant152 on 13/03/2026.
//

import SwiftUI

struct TitleCard: View {
    let title: String
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 14)
                .fill(.beigeClear)
                .frame(width: 197, height: 66)
            Text(title)
                .font(.system(size: 20))
                .fontWeight(.black)
                .foregroundStyle(.blueCustom)
        }
    }
}

#Preview {
    ZStack{
        TitleCard(title: "Air-liquide")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
