//
//  HomeView.swift
//  Nebulo
//
//  Created by apprenant152 on 23/04/2026.
//

import SwiftUI

/// Les destinations accessibles depuis l'accueil.
/// Un cas par écran : les suivants viendront s'ajouter ici.
enum HomeRoute: Hashable {
    case profil
}

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var route: HomeRoute?

    var body: some View {
        // Les contrôles portent la mise en page : eux seuls doivent se caler
        // sur l'écran. Le décor passe en `background` avec une taille fixe de
        // 1131 — celle que lui donnait le ZStack d'origine — et déborde de
        // part et d'autre comme avant, sans influencer la position du reste.
        VStack(spacing: 0) {
            totalCard
            navigation
                .padding(.top, 26)
            challenge
                .padding(.top, 54)
            Spacer(minLength: 0)
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                starfield
                spaceship
            }
            .frame(width: 1131, height: 1131)
            .allowsHitTesting(false)
        }
        .background(.accent)
        // L'écran porte son propre en-tête : la barre système ferait doublon.
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $route) { destination in
            switch destination {
            case .profil:
                ProfilView(viewModel: ProfileViewModel())
            }
        }
    }

    // MARK: Décor

    private var starfield: some View {
        Image("BackgroundHome")
            .resizable()
            .scaledToFill()
            .frame(width: 334.25, height: 539.76)
    }

    private var spaceship: some View {
        ZStack {
            Image("Starship50")
                .resizable()
                .scaledToFill()
                .frame(width: 420.96, height: 420.96)
                .offset(y: -380)

            Image("earth")
                .resizable()
                .scaledToFill()
                .frame(width: 1131)
        }
        .offset(y: 550)
    }

    // MARK: Contenu

    private var totalCard: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(.beigeClear)
            .frame(width: 146, height: 58)
            .overlay {
                Text("327.50 €")
                    .font(.system(size: 20))
                    .fontWeight(.black)
                    .foregroundStyle(.accent.opacity(0.47))
            }
    }

    /// Les trois accès de la maquette : actions à gauche, profil et forum à
    /// droite, plaqués contre les bords.
    private var navigation: some View {
        VStack(alignment: .trailing, spacing: 16) {
            HStack {
                ButtonNav(btnNav: {}, icon: "IconeActions")
                Spacer()
                ButtonNav(btnNav: { route = .profil }, icon: "IconeProfil")
            }
            ButtonNav(btnNav: {}, icon: "IconeForum")
        }
    }

    private var challenge: some View {
        VStack(spacing: 4) {
            Text("Challenges")
                .font(.system(size: 20))
                .fontWeight(.black)
                .foregroundStyle(.yellowCustom)
            Text("Augmente de 2€ tes dividendes")
                .font(.system(size: 20))
                .fontWeight(.medium)
                .foregroundStyle(.beige)
                .opacity(0.8)
        }
    }
}

#Preview {
    // La pile vit dans ContentView : sans elle ici, la navigation vers Profil
    // n'aurait nulle part où pousser.
    NavigationStack {
        HomeView()
    }
    .environmentObject(AuthViewModel())
}
