//
//  EditFieldDialog.swift
//  Nebulo
//
//  Created by apprenant152 on 15/09/2026.
//

import SwiftUI

/// Modal de modification d'un champ du profil.
///
/// Remplace `.alert` : l'alerte système n'est pas stylable et cassait la
/// direction artistique de l'app. Le champ de saisie réutilise
/// `CustomTextField`, comme les écrans de connexion et d'inscription.
struct EditFieldDialog: View {
    let title: String
    @Binding var value: String
    var errorMessage: String? = nil
    var isSaving: Bool = false
    var keyboard: UIKeyboardType = .default
    var capitalization: TextInputAutocapitalization = .words
    var isSecure: Bool = false
    let onCancel: () -> Void
    let onSave: () -> Void

    @FocusState private var isFocused: Bool

    private let cardWidth: CGFloat = 330
    private let contentWidth: CGFloat = 282

    var body: some View {
        ZStack {
            // Le fond assombri ferme le modal, comme une alerte système.
            // Noir et non `accent` : la carte porte déjà le bleu foncé des
            // vues, un fond de la même teinte l'effacerait.
            Color.black
                .opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            card
        }
    }

    private var card: some View {
        VStack(spacing: 18) {
            Text(title)
                .font(.system(size: 22))
                .fontWeight(.black)
                .foregroundStyle(.yellowCustom)

            CustomTextField(data: $value, label: title, widthTextField: contentWidth, isSecure: isSecure)
                .focused($isFocused)
                .keyboardType(keyboard)
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled()
                .textContentType(isSecure ? .newPassword : nil)
                .submitLabel(.done)
                .onSubmit(onSave)

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
                    .frame(width: contentWidth, alignment: .leading)
            }

            saveButton
            cancelButton
        }
        .padding(.vertical, 26)
        .frame(width: cardWidth)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.accent)
                .overlay {
                    // Un liseré discret détache la carte du fond assombri.
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(.beigeClear.opacity(0.14), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.5), radius: 24, y: 10)
        )
        .task { isFocused = true }
    }

    private var saveButton: some View {
        Button(action: onSave) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.orangeCustom)
                    .frame(width: contentWidth, height: 58)
                if isSaving {
                    ProgressView().tint(.accent)
                } else {
                    Text("Enregistrer")
                        .font(.system(size: 20))
                        .fontWeight(.black)
                        .foregroundStyle(.accent)
                }
            }
        }
        .disabled(isSaving)
    }

    private var cancelButton: some View {
        Button(action: onCancel) {
            Text("Annuler")
                .font(.system(size: 16))
                .fontWeight(.black)
                .foregroundStyle(.beige.opacity(0.75))
        }
        .disabled(isSaving)
    }
}

#Preview("Simple") {
    EditFieldDialog(
        title: "Prénom",
        value: .constant("Sébastien"),
        onCancel: {},
        onSave: {}
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}

#Preview("Mot de passe") {
    EditFieldDialog(
        title: "Mot de passe",
        value: .constant(""),
        capitalization: .never,
        isSecure: true,
        onCancel: {},
        onSave: {}
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}

#Preview("En erreur") {
    EditFieldDialog(
        title: "Email",
        value: .constant("sebastien@gmail.com"),
        errorMessage: "Un compte avec cet email existe déjà",
        keyboard: .emailAddress,
        capitalization: .never,
        onCancel: {},
        onSave: {}
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
