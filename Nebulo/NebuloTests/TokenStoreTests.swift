//
//  TokenStoreTests.swift
//  NebuloTests
//
//  Created by apprenant152 on 09/09/2026.
//

import Testing
@testable import Nebulo

/// Vérifie que le jeton transite bien par le trousseau iOS.
///
/// Sérialisé : `TokenStore` est un singleton adossé au trousseau du hôte de
/// test, les cas ne peuvent pas s'exécuter en parallèle sans se marcher dessus.
@Suite(.serialized)
struct TokenStoreTests {

    @Test func enregistreEtRelitLeJeton() {
        TokenStore.shared.clear()

        TokenStore.shared.save(token: "jeton-abc")

        #expect(TokenStore.shared.token == "jeton-abc")

        TokenStore.shared.clear()
    }

    @Test func remplaceLeJetonExistant() {
        TokenStore.shared.clear()

        TokenStore.shared.save(token: "premier-jeton")
        TokenStore.shared.save(token: "second-jeton")

        // Une seule entrée doit exister : la plus récente.
        #expect(TokenStore.shared.token == "second-jeton")

        TokenStore.shared.clear()
    }

    @Test func effaceLeJeton() {
        TokenStore.shared.save(token: "jeton-a-supprimer")

        TokenStore.shared.clear()

        #expect(TokenStore.shared.token == nil)
    }

    @Test func absenceDeJetonRenvoieNil() {
        TokenStore.shared.clear()

        #expect(TokenStore.shared.token == nil)
    }
}
