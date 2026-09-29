//
//  DeleteAccountDialog.swift
//  Nebulo
//
//  Created by apprenant152 on 29/09/2026.
//

import SwiftUI

/// Modal de suppression du compte.
///
/// Même montage que `ConfirmDialog` — fond assombri, carte bleue, titre jaune,
/// bouton rouge — avec, en plus, le mot de passe à ressaisir : le serveur le
/// revérifie avant d'effacer quoi que ce soit.
struct DeleteAccountDialog: View {
    let title: String
    let message: String
    /// Le badge du grade atteint, s'il est connu : ce que l'on s'apprête à
    /// perdre se voit avant de se lire.
    var badgeImage: String? = nil
    @Binding var password: String
    var errorMessage: String? = nil
    /// Vrai pendant l'appel : tout s'éteint, pour qu'un double toucher
    /// n'envoie pas deux suppressions.
    var isWorking: Bool = false
    let onCancel: () -> Void
    let onConfirm: () -> Void

    private let cardWidth: CGFloat = 330
    private let contentWidth: CGFloat = 282

    /// Sans mot de passe, le bouton reste éteint : il n'y a rien à vérifier.
    private var canConfirm: Bool { !password.isEmpty && !isWorking }

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { if !isWorking { onCancel() } }

            card
        }
    }

    private var card: some View {
        VStack(spacing: 16) {
            if let badgeImage {
                Image(badgeImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .accessibilityHidden(true)
            }

            Text(title)
                .font(.system(size: 22))
                .fontWeight(.black)
                .foregroundStyle(.yellowCustom)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.system(size: 15))
                .fontWeight(.medium)
                .foregroundStyle(.beigeClear.opacity(0.85))
                .multilineTextAlignment(.center)
                .frame(width: contentWidth)

            passwordField

            confirmButton
            cancelButton
        }
        .padding(.vertical, 26)
        .padding(.horizontal, 24)
        .frame(width: cardWidth)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.accent)
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(.beigeClear.opacity(0.14), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.5), radius: 24, y: 10)
        )
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Confirme avec ton mot de passe")
                .font(.system(size: 14))
                .fontWeight(.black)
                .foregroundStyle(.beige.opacity(0.75))

            CustomTextField(data: $password, label: "Mot de passe", widthTextField: contentWidth, isSecure: true)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                // `.password` et non `.newPassword` : on ressaisit le mot de
                // passe existant, le trousseau peut le proposer.
                .textContentType(.password)
                .submitLabel(.done)
                .onSubmit { if canConfirm { onConfirm() } }
                .disabled(isWorking)

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
            }
        }
        .frame(width: contentWidth, alignment: .leading)
    }

    private var confirmButton: some View {
        Button(action: onConfirm) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.red)
                    .frame(width: contentWidth, height: 58)
                if isWorking {
                    ProgressView().tint(.beigeClear)
                } else {
                    Text("Supprimer mon compte")
                        .font(.system(size: 20))
                        .fontWeight(.black)
                        .foregroundStyle(.beigeClear)
                }
            }
        }
        .disabled(!canConfirm)
        .opacity(canConfirm || isWorking ? 1 : 0.45)
    }

    private var cancelButton: some View {
        Button(action: onCancel) {
            Text("Rester à bord")
                .font(.system(size: 16))
                .fontWeight(.black)
                .foregroundStyle(.beige.opacity(0.75))
        }
        .disabled(isWorking)
    }
}

#Preview("Vide") {
    DeleteAccountDialog(
        title: "Quitter l'équipage ?",
        message: "Sébastien, ta fusée, tes planètes, tes actions et tes messages du forum partiront en poussière d'étoiles. Aucun retour possible depuis ce trou noir.",
        badgeImage: GradeCatalog.all.first?.image,
        password: .constant(""),
        onCancel: {},
        onConfirm: {}
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}

#Preview("En erreur") {
    DeleteAccountDialog(
        title: "Quitter l'équipage ?",
        message: "Ta fusée, tes planètes, tes actions et tes messages du forum partiront en poussière d'étoiles. Aucun retour possible depuis ce trou noir.",
        password: .constant(""),
        errorMessage: "Mot de passe incorrect",
        onCancel: {},
        onConfirm: {}
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
