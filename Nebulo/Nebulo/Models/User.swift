//
//  User.swift
//  Nebulo
//
//  Created by apprenant152 on 27/04/2026.
//

import Foundation

struct User {
    let id: UUID
    let firstname: String
    let lastname: String
    let email: String
    let energy: Int
    let grade: String
    let dateOfBirth: Date
}

/// Utilisateur d'exemple pour les previews.
let fakeUser = User(
    id: UUID(),
    firstname: "Sébastien",
    lastname: "Besse",
    email: "sebastien@gmail.com",
    energy: 80,
    grade: "Explorateur",
    dateOfBirth: Date(timeIntervalSince1970: 642_000_000)
)
