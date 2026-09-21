//
//  ProfilView.swift
//  Nebulo
//
//  Created by apprenant152 on 14/09/2026.
//

import SwiftUI

struct ProfilView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: ProfileViewModel
    /// La fiche d'une planète se présente par-dessus le profil plutôt que
    /// de s'y empiler : on en revient, on n'y progresse pas.
    @State private var selectedPlanet: Planet?

    /// Le ViewModel est injecté, sans valeur par défaut : celle-ci serait
    /// évaluée hors de l'acteur principal. Les appelants le construisent donc
    /// eux-mêmes, depuis un contexte qui y est déjà.
    ///
    /// C'est aussi ce qui permet aux previews d'afficher l'écran rempli :
    /// une preview n'a ni jeton dans le trousseau ni serveur à appeler.
    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    HeaderBar(title: "Profil")
                    identity
                    grades
                    planets
                    logoutButton
                }
                .padding(.bottom, 24)
            }


            if let field = viewModel.editingField {
                EditFieldDialog(
                    title: field.title,
                    value: $viewModel.draft,
                    errorMessage: viewModel.errorMessage,
                    isSaving: viewModel.isSaving,
                    keyboard: field == .email ? .emailAddress : .default,
                    capitalization: field == .firstname || field == .lastname ? .words : .never,
                    isSecure: field.isSecure,
                    onCancel: { viewModel.cancelEditing() },
                    onSave: { Task { await viewModel.saveEditing() } }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.18), value: viewModel.editingField)
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
        // La planète est déjà en mémoire : l'écran de détail ne lit rien au
        // serveur, il n'y a donc rien à recharger.
        .fullScreenCover(item: $selectedPlanet) { planet in
            PlanetDetailView(
                planets: viewModel.sortedPlanets,
                selected: planet,
                energy: viewModel.user?.energy ?? 0
            )
        }
    }

    // MARK: Identité
    private var identity: some View {
        VStack(alignment: .leading, spacing: 14) {
            if viewModel.isLoading && viewModel.user == nil {
                ProgressView()
                    .tint(.beigeClear)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if let user = viewModel.user {
                HStack(spacing: 10) {
                    editableField(user.firstname, field: .firstname)
                    editableField(user.lastname, field: .lastname)
                }
                editableField(user.email, field: .email, underlined: true)
                // La vraie valeur n'est jamais connue du client : on affiche un
                // masque de longueur fixe, qui ne renseigne pas sur le mot de passe.
                editableField("•••••••••••••••••••••••", field: .password)
            }

            // Quand le modal est ouvert, il porte déjà le message.
            if let error = viewModel.errorMessage, viewModel.editingField == nil {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundStyle(.red)
            }
        }
        .padding(.horizontal, 20)
    }

    /// Toucher un champ ouvre sa modification. Le libellé sert d'indication
    /// d'accessibilité : rien à l'écran ne dit qu'un champ est modifiable.
    private func editableField(_ value: String, field: ProfileField, underlined: Bool = false) -> some View {
        Button {
            viewModel.startEditing(field)
        } label: {
            fieldBox(value, underlined: underlined)
        }
        .accessibilityLabel(
            field.isSecure
            ? "\(field.title), masqué. Toucher pour modifier."
            : "\(field.title) : \(value). Toucher pour modifier."
        )
    }

    private func fieldBox(_ value: String, underlined: Bool = false) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.beigeClear)
                .frame(height: 58)
            Text(value)
                .font(.system(size: 24))
                .fontWeight(.black)
                .foregroundStyle(.accent.opacity(0.47))
                .underline(underlined)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 14)
        }
    }

    // MARK: Grades

    private var grades: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Grades")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(GradeCatalog.all) { badge in
                        BadgeCard(badge: badge, isCurrent: badge == viewModel.currentGrade)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: Planètes

    private var planets: some View {
        VStack(alignment: .leading) {
            sectionTitle("Planètes")

            if viewModel.isLoading {
                ProgressView()
                    .tint(.beigeClear)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else if !viewModel.hasLoaded {
                // Le chargement a échoué : ne pas inviter à enregistrer un
                // dividende, le problème n'est pas là.
                retryRow
            } else if viewModel.sortedPlanets.isEmpty {
                Text("Enregistre un dividende pour décoller.")
                    .font(.system(size: 16))
                    .foregroundStyle(.beige.opacity(0.7))
                    .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 3) {
                        ForEach(viewModel.sortedPlanets) { planet in
                            // Le geste est posé ici plutôt que dans le
                            // composant : `PlanetCard` sert aussi ailleurs, où
                            // rien ne doit s'ouvrir.
                            PlanetCard(planet: planet, size: 185)
                                .contentShape(Rectangle())
                                // Les planètes verrouillées s'ouvrent aussi :
                                // leur fiche dit ce qu'il manque pour y aller.
                                .onTapGesture { selectedPlanet = planet }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    private var retryRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.errorMessage ?? "Profil indisponible pour le moment.")
                .font(.system(size: 16))
                .foregroundStyle(.beige.opacity(0.7))
            Button("Réessayer") {
                Task { await viewModel.load() }
            }
            .font(.system(size: 16, weight: .black))
            .foregroundStyle(.orangeCustom)
        }
        .padding(.horizontal, 20)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20))
            .fontWeight(.black)
            .foregroundStyle(.yellowCustom)
            .padding(.horizontal, 20)
    }

    // MARK: Déconnexion

    private var logoutButton: some View {
        HStack {
            Spacer()
            ButtonAction(name: "Déconnexion") {
                authViewModel.logout()
            }
            Spacer()
        }
    }
}

#Preview {
    let viewModel = ProfileViewModel()
    viewModel.user = fakeUser
    viewModel.planets = fakePlanets
    viewModel.hasLoaded = true
    viewModel.hasAttemptedLoad = true

    return ProfilView(viewModel: viewModel)
        .environmentObject(AuthViewModel())
}
