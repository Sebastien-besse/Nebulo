//
//  NebuloApp.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import SwiftUI

@main
struct NebuloApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
