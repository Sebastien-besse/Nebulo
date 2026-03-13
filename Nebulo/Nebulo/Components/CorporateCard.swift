//
//  CorporateCard.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import SwiftUI

struct CorporateCard: View {
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 18)
                .fill(.beigeClear.opacity(0.2))
                .frame(width: 342, height: 212)
                .glassEffectTransition(GlassEffectTransition.matchedGeometry)
            VStack(spacing: 30){
                HStack(alignment: .bottom){
                    Spacer()
                    ZStack{
                        RoundedRectangle(cornerRadius: 7)
                            .fill(.orangeCustom)
                            .frame(width: 91, height: 30)
                        Text("21 fev 2026")
                            .font(.system(size: 14))
                            .fontWeight(.black)
                            .foregroundStyle(.accent)
                        
                    }
                }
                .frame(width: 320)
                .padding(.top, 10)

                RoundedRectangle(cornerRadius: 9)
                    .fill(.accent)
                    .frame(width: 204, height: 70.15)
                    .overlay {
                        Text("Air-liquide")
                            .font(.system(size: 32))
                            .fontWeight(.black)
                            .foregroundStyle(.beigeClear)
                    }
                cardData()
            }
        }
    }
    
    func cardData() -> some View{
        ZStack{
            RoundedRectangle(cornerRadius: 7)
                .fill(.orangeCustom)
                .frame(width: 158, height: 52.62)
            HStack(spacing: 48){
                circleVote(icon: "fire")
                circleVote(icon: "cold")
            }
            .fontWeight(.black)
            .foregroundStyle(.accent)
        }
        .padding(.top, -10)
    }
    
    func circleVote(icon: String)-> some View{
        ZStack{
            Circle()
                .fill(.accent)
                .frame(width: 48)
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 32)

        }
    }
}

#Preview {
    ZStack{
        CorporateCard()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
    
}
