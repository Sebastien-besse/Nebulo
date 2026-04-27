//
//  CustomTextField.swift
//  Nebulo
//
//  Created by apprenant152 on 13/03/2026.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var data: String
    let label: String
    let widthTextField: CGFloat
    var isSecure: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.beigeClear)
                .frame(width: widthTextField, height: 62)
            if isSecure {
                SecureField(label, text: $data)
                    .font(.system(size: 20))
                    .fontWeight(.black)
                    .foregroundStyle(.accent.opacity(0.47))
                    .padding(.leading)
            } else {
                TextField(text: $data) {
                    Text(label)
                }
                .font(.system(size: 20))
                .fontWeight(.black)
                .foregroundStyle(.accent.opacity(0.47))
                .padding(.leading)
            }
        }
        .frame(width: widthTextField, height: 80)
    }
}

#Preview {
    ZStack {
        CustomTextField(data: .constant(""), label: "Password", widthTextField: 315)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
