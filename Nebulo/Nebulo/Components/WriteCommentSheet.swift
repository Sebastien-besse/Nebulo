//
//  WriteCommentSheet.swift
//  Nebulo
//
//  Created by apprenant152 on 23/09/2026.
//

import SwiftUI

/// Feuille d'écriture d'un commentaire sur une entreprise.
///
/// Une feuille plutôt qu'un modal centré : on écrit ici, on ne confirme pas.
/// Elle monte du bas, sous le pouce, et laisse voir la fiche derrière son
/// bord — la carte assombrissait tout l'écran pour deux phrases.
///
/// Le champ est un `TextEditor` et non le `CustomTextField` du profil : un
/// commentaire tient sur plusieurs lignes, et une ligne unique qui défile
/// horizontalement empêche de se relire avant de publier.
struct WriteCommentSheet: View {
    /// Le nom de l'entreprise commentée, rappelé sous le titre : la feuille
    /// couvre la fiche, on ne voit plus de quoi on parle.
    let companyName: String
    @Binding var draft: String
    var errorMessage: String? = nil
    /// Vrai pendant l'envoi : les deux boutons s'éteignent, pour qu'un double
    /// toucher ne publie pas deux fois.
    var isSending: Bool = false
    let onCancel: () -> Void
    let onPublish: () -> Void

    @FocusState private var isWriting: Bool

    private let contentWidth: CGFloat = 320

    var body: some View {
        ZStack {
            // La feuille porte le bleu des écrans : sans lui, elle arriverait
            // sur le gris du système, seule surface de l'application à ne pas
            // suivre la direction artistique.
            Color.accentColor.ignoresSafeArea()

            VStack(spacing: 18) {
                header
                // Le champ prend toute la place que les autres laissent : il
                // grandit avec la feuille quand on la déplie, et rend ce qu'il
                // faut au clavier quand il monte.
                editor

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .fontWeight(.black)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(width: contentWidth)
                }

                // Les boutons sont poussés en bas de feuille par le champ, et
                // non posés sous lui : c'est là que le pouce les trouve.
                publishButton
                cancelButton
            }
            .padding(.top, 28)
            .padding(.bottom, 28)
            .padding(.horizontal, 24)
        }
        // Le clavier monte seul : on est venu écrire, pas lire.
        .onAppear { isWriting = true }
        // Deux hauteurs : la feuille s'ouvre à mi-écran, assez pour le champ et
        // le bouton, et se déplie si l'on écrit long.
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.accent)
        // Sans cela le système assombrit la fiche derrière, et le bleu de
        // l'écran vire au gris pour le temps de la feuille. Laisser le fond
        // interactif retire ce voile : on continue de voir l'entreprise dont
        // on parle, de sa vraie couleur. Le voile revient si l'on déplie en
        // grand, où la feuille couvre tout de toute façon.
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("Nouveau commentaire")
                .font(.system(size: 22))
                .fontWeight(.black)
                .foregroundStyle(.yellowCustom)
                .multilineTextAlignment(.center)

            Text(companyName)
                .font(.system(size: 15))
                .fontWeight(.medium)
                .foregroundStyle(.beigeClear.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    /// Le même champ que le fil de réponses : plaque crème, texte bleu, et le
    /// texte d'invite posé par-dessus — `TextEditor` n'en a pas.
    private var editor: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(.beigeClear)
            .frame(width: contentWidth)
            // Un plancher, pas une hauteur : la feuille à mi-écran lui laisse
            // près du double, et le dépliage tout le reste.
            .frame(minHeight: 150, maxHeight: .infinity)
            .overlay(alignment: .topLeading) {
                ZStack(alignment: .topLeading) {
                    if draft.isEmpty {
                        Text("Votre commentaire...")
                            .font(.system(size: 18))
                            .fontWeight(.black)
                            .foregroundStyle(.accent.opacity(0.47))
                            .padding(.top, 20)
                            .padding(.leading, 24)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $draft)
                        .font(.system(size: 18))
                        .fontWeight(.black)
                        .foregroundStyle(.accent)
                        .scrollContentBackground(.hidden)
                        .focused($isWriting)
                        .padding(.top, 13)
                        .padding(.leading, 19)
                        .padding(.trailing, 16)
                        .padding(.bottom, 12)
                }
            }
    }

    private var publishButton: some View {
        Button {
            isWriting = false
            onPublish()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.orangeCustom)
                    .frame(width: contentWidth, height: 58)
                if isSending {
                    ProgressView().tint(.accent)
                } else {
                    Text("Publier")
                        .font(.system(size: 20))
                        .fontWeight(.black)
                        .foregroundStyle(.accent)
                }
            }
        }
        .disabled(isSending)
    }

    /// La feuille se referme aussi d'un glissement vers le bas. Le bouton reste :
    /// il éteint le clavier au passage, ce que le glissement ne fait pas quand
    /// le champ tient encore le focus.
    private var cancelButton: some View {
        Button(action: onCancel) {
            Text("Annuler")
                .font(.system(size: 16))
                .fontWeight(.black)
                .foregroundStyle(.beige.opacity(0.75))
        }
        .disabled(isSending)
    }
}

#Preview {
    Color.accentColor
        .sheet(isPresented: .constant(true)) {
            WriteCommentSheet(
                companyName: "TotalEnergies",
                draft: .constant(""),
                onCancel: {},
                onPublish: {}
            )
        }
}
