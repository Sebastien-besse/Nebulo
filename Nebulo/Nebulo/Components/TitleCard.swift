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
        
        VStack{
    
            Text(title)
                .font(.system(size: 32))
                .fontWeight(.black)
                .foregroundStyle(.yellowCustom)
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
