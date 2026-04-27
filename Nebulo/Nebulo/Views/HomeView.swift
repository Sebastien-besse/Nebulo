//
//  HomeView.swift
//  Nebulo
//
//  Created by apprenant152 on 23/04/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        ZStack{
            Image("BackgroundHome")
                .resizable()
                .scaledToFill()
                .frame(width: 334.25, height: 539.76)
            VStack(spacing: 180){
                
//                Button(action: { viewModel.logout() }) {
//                    Text("Déconnexion")
//                        .font(.system(size: 14))
//                        .fontWeight(.bold)
//                        .foregroundStyle(.beigeClear)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 8)
//                        .background(RoundedRectangle(cornerRadius: 10).fill(.red.opacity(0.7)))
//                }
                
                RoundedRectangle(cornerRadius: 18)
                    .fill(.beigeClear)
                    .frame(width: 146, height: 58)
                    .overlay{
                        Text("327.50 €")
                            .font(.system(size: 20))
                            .fontWeight(.black)
                            .foregroundStyle(.accent.opacity(0.47))
                    }
                VStack{
                    Text("Challenges")
                         .font(.system(size: 20))
                         .fontWeight(.black)
                         .foregroundStyle(.yellowCustom)
                     Text("Augmente de 2€ tes dicidendes")
                          .font(.system(size: 20))
                          .fontWeight(.medium)
                          .foregroundStyle(.beige).opacity(0.8)
                }

  
                VStack(alignment: .trailing, spacing: 20){
                    HStack{
                        ButtonNav(btnNav: {}, icon: "IconeActions")
                        Spacer()
                        ButtonNav(btnNav: {}, icon: "IconeProfil")

                    }
                    ButtonNav(btnNav: {}, icon: "IconeForum")
                }
                
            }
            .offset(y: -80)
        
                ZStack{
                    Image("Starship50")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 420.96, height: 420.96)
                        .offset(y: -380)
                    
                    Image("earth")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 1131)
                }
                .offset(y: 550)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.accent)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
