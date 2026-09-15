//
//  ContentView.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if viewModel.isAuthenticated {
            // La pile est posée ici plutôt que dans HomeView : elle doit
            // survivre à la navigation, et disparaître à la déconnexion.
            NavigationStack {
                HomeView()
            }
        } else {
            AuthentificationView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
