//
//  UpdateProfileRequestDTO.swift
//  Nebulo
//
//  Created by apprenant152 on 15/09/2026.
//

import Foundation

/// Corps de `PUT /users/me`.
///
/// L'API attend le profil complet, pas le seul champ modifié : le ViewModel
/// renvoie donc les valeurs courantes avec celle qui change.
/// `energy` et `grade` sont volontairement absents — le serveur les pilote et
/// refuse qu'un client les fixe.
struct UpdateProfileRequestDTO: Encodable {
    let firstname: String
    let lastname: String
    let email: String
    let dateOfBirth: Date
    /// Renseigné uniquement lors d'un changement de mot de passe. Absent, le
    /// serveur conserve le hash existant.
    let password: String?
}
