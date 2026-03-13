//
//  TextField.swift
//  Nebulo
//
//  Created by apprenant152 on 13/03/2026.
//

import SwiftUI

struct CustomTextField: View {
    @State var data: String = ""
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 14)
                .fill(.beigeClear)
                .frame(width: 315, height: 80)
            TextField(text: $data){
                Text("Email")
            }
            .font(.system(size: 24))
            .fontWeight(.black)
            .foregroundStyle(.accent.opacity(0.47))
            .padding(.leading)
        }
        .frame(width: 315, height: 80)
    }
}

#Preview {
    ZStack{
        CustomTextField()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
