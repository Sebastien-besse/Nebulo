//
//  SocietyView.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import SwiftUI
import CardCarousel

struct SocietyView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: SocietyViewModel

    /// Le ViewModel est injecté, sans valeur par défaut : celle-ci serait
    /// évaluée hors de l'acteur principal. C'est aussi ce qui permet aux
    /// previews d'afficher l'écran rempli, sans jeton ni serveur.
    init(viewModel: SocietyViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Pas de bouton à droite : la maquette n'en montre aucun.
                HeaderBar(title: "Société")
                content
            }
        }
        // L'écran a son propre bouton retour, dessiné dans l'en-tête.
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            // Une preview arrive avec son état déjà posé : ne rien aller
            // chercher, elle n'a ni trousseau ni réseau.
            if !viewModel.hasAttemptedLoad { await viewModel.load() }
        }
        // Le jeton n'est plus accepté : on sort de la session plutôt que
        // d'afficher une erreur que l'utilisateur ne peut pas résoudre.
        .onChange(of: viewModel.sessionExpired) { _, expired in
            if expired { authViewModel.logout() }
        }
    }

    // MARK: Contenu

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.company == nil {
            Spacer()
            ProgressView()
                .tint(.beigeClear)
            Spacer()
        } else if let error = viewModel.errorMessage, viewModel.company == nil {
            Spacer()
            Text(error)
                .font(.system(size: 16))
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        } else if let company = viewModel.company {
            VStack(alignment: .leading, spacing: 0) {
                nameChip(company.name)
                sectionTitle("Description")
                    .padding(.top, 31)
                description(company.description)
                    .padding(.top, 8)
                sectionTitle("Commentaires")
                    .padding(.top, 37)
                comments
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.top, 38)
        } else {
            Spacer()
        }
    }

    /// La puce porte les couleurs inverses du reste de l'écran : fond crème,
    /// texte bleu. C'est le seul endroit de l'application où ce bleu sert.
    private func nameChip(_ name: String) -> some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(.beigeClear)
            .frame(width: 197, height: 66)
            .overlay {
                Text(name)
                    .font(.system(size: 32))
                    .fontWeight(.black)
                    .foregroundStyle(.blueCustom)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
            .fontWeight(.black)
            .foregroundStyle(.yellowCustom)
            .padding(.leading, 3)
    }

    private func description(_ text: String) -> some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(.purpleClear)
            .frame(height: 125)
            .overlay {
                Text(text)
                    .font(.system(size: 14))
                    .fontWeight(.black)
                    .foregroundStyle(.beigeClear)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 31)
            }
    }

    @ViewBuilder
    private var comments: some View {
        if viewModel.posts.isEmpty {
            Text(viewModel.hasLoaded
                 ? "Aucun message sur cette entreprise. Ouvre la discussion."
                 : "Fil indisponible pour le moment.")
                .font(.system(size: 16))
                .foregroundStyle(.beige.opacity(0.7))
                .padding(.top, 29)
        } else {
            // Le carrousel décale ses voisines mais ne les estompe pas : la
            // maquette les pose à 24 %, c'est donc la carte qui s'en charge.
            Carousel(
                viewModel.posts,
                index: $viewModel.activeIndex,
                sidesScaling: 1
            ) { post in
                CardCarouselPost(post: post)
                    .opacity(viewModel.isActive(post) ? 1 : 0.24)
            }
            .frame(height: 360)
            .padding(.top, 29)
        }
    }
}

#Preview {
    let viewModel = SocietyViewModel(companyId: fakeCompany.id)
    viewModel.company = fakeCompany
    viewModel.posts = Array(fakePosts.prefix(3))
    viewModel.hasLoaded = true
    viewModel.hasAttemptedLoad = true

    // La pile vit dans ContentView : sans elle ici, le bouton retour n'aurait
    // rien à dépiler.
    return NavigationStack {
        SocietyView(viewModel: viewModel)
    }
    .environmentObject(AuthViewModel())
}
