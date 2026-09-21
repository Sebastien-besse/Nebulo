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
    /// La maquette d'authentification pose des champs de 62 points et du texte
    /// de 20 ; celle de l'ajout d'action, 80 et 24. Les valeurs par défaut sont
    /// celles de l'authentification, qui est arrivée la première.
    var heightTextField: CGFloat = 62
    var fontSize: CGFloat = 20
    /// Les maquettes de formulaire retirent le texte de 37 points du bord,
    /// celle d'authentification de 16.
    var leadingPadding: CGFloat = 16
    var keyboard: UIKeyboardType = .default
    var capitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.beigeClear)
                .frame(width: widthTextField, height: heightTextField)
            if isSecure {
                SecureField(label, text: $data)
                    .font(.system(size: fontSize))
                    .fontWeight(.black)
                    .foregroundStyle(.accent.opacity(0.47))
                    .padding(.leading, leadingPadding)
            } else {
                TextField(text: $data) {
                    Text(label)
                }
                .font(.system(size: fontSize))
                .fontWeight(.black)
                .foregroundStyle(.accent.opacity(0.47))
                .keyboardType(keyboard)
                .textInputAutocapitalization(capitalization)
                .padding(.leading, leadingPadding)
            }
        }
        .frame(width: widthTextField, height: heightTextField + 18)
    }
}

#Preview {
    ZStack {
        VStack(spacing: 22) {
            CustomTextField(data: .constant(""), label: "Password", widthTextField: 315)
            CustomTextField(data: .constant(""), label: "Nom", widthTextField: 315,
                            heightTextField: 80, fontSize: 24)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
