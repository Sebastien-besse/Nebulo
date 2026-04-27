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
            HomeView()
        } else {
            AuthentificationView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
