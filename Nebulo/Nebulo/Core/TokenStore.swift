//
//  TokenStore.swift
//  Nebulo
//
//  Created by apprenant152 on 27/04/2026.
//

import Foundation

final class TokenStore {
    static let shared = TokenStore()
    private let key = "nebulo_jwt_token"

    private init() {}

    var token: String? {
        UserDefaults.standard.string(forKey: key)
    }

    func save(token: String) {
        UserDefaults.standard.set(token, forKey: key)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
