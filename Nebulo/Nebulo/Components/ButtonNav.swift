//
//  ButtonNav.swift
//  Nebulo
//
//  Created by apprenant152 on 16/03/2026.
//

import SwiftUI

struct ButtonNav: View {
    var btnNav : ()->Void
    var icon: String
    var body: some View {
        Button(action: btnNav) {
            ZStack{
                RoundedRectangle(cornerRadius: 5)
                    .fill(.beigeClear)
                    .frame(width: 46.61, height: 46.61)
                Image(icon)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36.25, height: 31.32)
            }
        }
    }
}

#Preview {
    ButtonNav(btnNav: {print("Navigate to ➡️")}, icon: "IconeProfil")
}
