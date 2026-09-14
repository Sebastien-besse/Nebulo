//
//  TokenStore.swift
//  Nebulo
//
//  Created by apprenant152 on 27/04/2026.
//

import Foundation
import Security

/// Stockage du jeton JWT dans le trousseau iOS.
///
/// Le trousseau est chiffré par le système et lié au code de déverrouillage de
/// l'appareil, contrairement à `UserDefaults` qui écrit un fichier en clair dans
/// le conteneur de l'application.
///
/// L'accessibilité retenue est `AfterFirstUnlockThisDeviceOnly` : le jeton est
/// lisible dès le premier déverrouillage suivant un redémarrage, et n'est jamais
/// synchronisé ni restauré sur un autre appareil. Une session appartient à un
/// appareil ; les données de l'utilisateur, elles, sont sur le serveur.
final class TokenStore {
    static let shared = TokenStore()

    private let service = "com.nebulo.auth"
    private let account = "jwt"

    /// Ancienne clé `UserDefaults`, conservée le temps de la migration.
    private let legacyKey = "nebulo_jwt_token"

    private init() {
        migrateLegacyTokenIfNeeded()
    }

    var token: String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return token
    }

    func save(token: String) {
        guard let data = token.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        // Un seul jeton à la fois : on remplace l'existant s'il y en a un.
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            var newItem = query
            newItem.merge(attributes) { current, _ in current }
            SecItemAdd(newItem as CFDictionary, nil)
        }
    }

    func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// Déplace un jeton laissé dans `UserDefaults` par une version antérieure.
    ///
    /// Évite de déconnecter les comptes déjà installés lors de la mise à jour.
    private func migrateLegacyTokenIfNeeded() {
        guard let legacyToken = UserDefaults.standard.string(forKey: legacyKey) else { return }

        if token == nil {
            save(token: legacyToken)
        }
        UserDefaults.standard.removeObject(forKey: legacyKey)
    }
}
