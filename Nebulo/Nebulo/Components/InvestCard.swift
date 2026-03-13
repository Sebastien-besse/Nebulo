//
//  InvestCard.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import SwiftUI

struct InvestCard: View {
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 18)
                .fill(.beigeClear.opacity(0.2))
                .frame(width: 306, height: 171)
                .glassEffectTransition(GlassEffectTransition.matchedGeometry)
            VStack(spacing: 30){
                RoundedRectangle(cornerRadius: 9)
                    .fill(.accent)
                    .frame(width: 139, height: 50)
                    .overlay {
                        Text("Nike")
                            .font(.system(size: 20))
                            .fontWeight(.black)
                            .foregroundStyle(.beigeClear)
                    }
               cardsData
            }
                
        }
    }
    
    var cardsData: some View{
        HStack(spacing: 73){
            cardData(w: 90, h: 56, title: "🚀 Actions", value: 128, color: .yellowCustom)
            cardData(w: 120, h: 56, title: "💶 Dividendes", value: 128, color: .greenCustom)
        }

    }
    
    func cardData(w: CGFloat, h: CGFloat, title: String, value: Int, color: Color) -> some View{
        ZStack{
            RoundedRectangle(cornerRadius: 7)
                .fill(color)
                .frame(width: w, height: h)
            VStack{
                Text(title)
                    .font(.system(size: 14))
                Text("\(value)€")
                    .font(.system(size: 20))
            }
            .fontWeight(.black)
            .foregroundStyle(.accent)
            
        }
    }
}

#Preview {
    ZStack{
        InvestCard()
            
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
    
}
