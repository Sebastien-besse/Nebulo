//
//  AuthentificationView.swift
//  Nebulo
//
//  Created by apprenant152 on 16/03/2026.
//

import SwiftUI

struct AuthentificationView: View {
    @State var email: String = ""
    @State var password: String = ""
    var body: some View {
        ZStack{
            VStack(spacing: 70){
                Image("Logo-Nebulo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 245, height: 245)
                
                textFieldGroup
                
                Button {
                    print("connecter")
                } label: {
                    ZStack{
                        Circle()
                            .fill(.orangeCustom)
                            .frame(width: 100)
                        Image("RocketConnexion")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 75, height: 92)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.accent)
    }
    
    
    var textFieldGroup : some View{
        VStack(spacing: 25){
            CustomTextField(data: email, label: "Email")
            CustomTextField(data: password, label: "Mot de passe")
                .textContentType(.password)
        }
    }
}

#Preview {
    AuthentificationView()
}
