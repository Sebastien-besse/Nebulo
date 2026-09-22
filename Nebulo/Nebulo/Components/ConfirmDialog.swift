//
//  ConfirmDialog.swift
//  Nebulo
//
//  Created by apprenant152 on 22/09/2026.
//

import SwiftUI

/// Modal de confirmation d'une action sans retour en arrière.
///
/// Reprend le montage d'`EditFieldDialog` — fond assombri, carte bleue,
/// titre jaune — pour la même raison : l'alerte système n'est pas stylable et
/// casserait la direction artistique. Le bouton de confirmation est rouge,
/// couleur que l'application ne sert qu'aux erreurs : elle dit ici ce qu'elle
/// dit ailleurs, que quelque chose ne se rattrape pas.
struct ConfirmDialog: View {
    let title: String
    let message: String
    var confirmLabel: String = "Supprimer"
    /// Vrai pendant l'appel : les deux boutons s'éteignent, pour qu'un double
    /// toucher n'envoie pas deux suppressions.
    var isWorking: Bool = false
    let onCancel: () -> Void
    let onConfirm: () -> Void

    private let cardWidth: CGFloat = 330
    private let contentWidth: CGFloat = 282

    var body: some View {
        ZStack {
            // Le fond assombri annule, comme une alerte système. Noir et non
            // `accent` : la carte porte déjà le bleu foncé des vues, un fond
            // de la même teinte l'effacerait.
            Color.black
                .opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { if !isWorking { onCancel() } }

            card
        }
    }

    private var card: some View {
        VStack(spacing: 18) {
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
                    // Un liseré discret détache la carte du fond assombri.
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(.beigeClear.opacity(0.14), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.5), radius: 24, y: 10)
        )
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
                    Text(confirmLabel)
                        .font(.system(size: 20))
                        .fontWeight(.black)
                        .foregroundStyle(.beigeClear)
                }
            }
        }
        .disabled(isWorking)
    }

    private var cancelButton: some View {
        Button(action: onCancel) {
            Text("Annuler")
                .font(.system(size: 16))
                .fontWeight(.black)
                .foregroundStyle(.beige.opacity(0.75))
        }
        .disabled(isWorking)
    }
}

#Preview {
    ConfirmDialog(
        title: "Supprimer la réponse ?",
        message: "Elle disparaîtra du fil pour tout le monde. C'est définitif.",
        onCancel: {},
        onConfirm: {}
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.accentColor)
}
