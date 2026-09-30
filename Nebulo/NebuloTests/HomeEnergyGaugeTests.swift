//
//  HomeEnergyGaugeTests.swift
//  NebuloTests
//
//  Created by apprenant152 on 30/09/2026.
//

import Foundation
import Testing
@testable import Nebulo

/// La jauge de la fusée ne doit rien affirmer tant que les planètes ne sont
/// pas arrivées : elle affichait 100 % sur un chargement échoué.
@MainActor
struct HomeEnergyGaugeTests {

    private func planet(_ name: String, threshold: Int, energy: Int) -> Planet {
        Planet(
            id: UUID(), image: name.lowercased(), name: name, nickname: "",
            surface: 0, temperature: 0, description: "",
            energyThreshold: threshold,
            locked: energy < threshold,
            unlockedAt: energy < threshold ? nil : .now
        )
    }

    @Test func sansPlanetesLaJaugeEstVideEtSansChiffre() {
        let viewModel = HomeViewModel(tokenProvider: { nil })
        #expect(viewModel.energyProgress == 0)
        #expect(viewModel.energyPercentLabel == "– %")
    }

    @Test func auBoutDuVoyageLaJaugeEstPleine() {
        let viewModel = HomeViewModel(tokenProvider: { nil })
        viewModel.planets = [
            planet("Terre", threshold: 0, energy: 5_000),
            planet("Neptune", threshold: 3_600, energy: 5_000)
        ]
        #expect(viewModel.energyProgress == 1)
        #expect(viewModel.energyPercentLabel == "100 %")
    }

    @Test func laJaugeMesureDepuisLaDernierePlaneteAtteinte() {
        let viewModel = HomeViewModel(tokenProvider: { nil })
        viewModel.planets = [
            planet("Jupiter", threshold: 1_100, energy: 1_200),
            planet("Saturne", threshold: 1_700, energy: 1_200)
        ]
        viewModel.summary = DividendSummary(
            totalAllTime: 0, totalThisMonth: 0, totalThisYear: 0, count: 0, energy: 1_200
        )
        #expect(viewModel.energyPercentLabel == "16 %")
    }
}
