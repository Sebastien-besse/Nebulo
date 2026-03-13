//
//  ButtonAction.swift
//  Nebulo
//
//  Created by apprenant152 on 13/03/2026.
//

import SwiftUI

struct ButtonAction: View {
    let name: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack{
                RoundedRectangle(cornerRadius: 14)
                    .fill(.orangeCustom)
                    .frame(width: 223, height: 58)
                Text(name)
                    .font(.system(size: 20))
                    .fontWeight(.black)
                    .foregroundStyle(.accent)
            }
        }
    }
}

#Preview {
    ZStack{
        ButtonAction(name: "Déconnexion", action: {
            print("Vous êtes déconnecter")
        })
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)

}
