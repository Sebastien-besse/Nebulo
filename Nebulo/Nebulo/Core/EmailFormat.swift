//
//  EmailFormat.swift
//  Nebulo
//
//  Created by apprenant152 on 22/09/2026.
//

import SwiftUI

extension String {
    /// L'adresse telle qu'elle part au serveur : sans espaces autour, et tout
    /// en minuscules.
    ///
    /// La casse n'a aucune valeur dans une adresse — `Jean@Nebulo.fr` et
    /// `jean@nebulo.fr` désignent la même boîte. L'API normalise de son côté ;
    /// le faire aussi ici évite d'afficher un profil dont l'email ne
    /// ressemble pas à celui qui vient d'être enregistré.
    var normalizedEmail: String {
        trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

extension Binding where Value == String {
    /// Le champ écrit en minuscules à mesure qu'on tape.
    ///
    /// `textInputAutocapitalization(.never)` ne suffit pas : il ne gouverne
    /// que le clavier logiciel. Un clavier matériel, un collage ou une
    /// saisie automatique passent à côté. Les espaces, eux, ne sont retirés
    /// qu'à l'envoi — les couper sous les doigts empêcherait d'en taper un
    /// par erreur puis de le reprendre.
    var lowercasedEmail: Binding<String> {
        Binding<String>(
            get: { wrappedValue },
            set: { wrappedValue = $0.lowercased() }
        )
    }
}
