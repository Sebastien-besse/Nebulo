//
//  AddPostView.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import SwiftUI
import CardCarousel

struct AddPostView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: AddPostViewModel
    @Environment(\.dismiss) private var dismiss

    /// Appelé une fois le message publié, pour que le fil se recharge avant
    /// de réapparaître.
    var onCreated: () -> Void = {}

    /// Le ViewModel est injecté, sans valeur par défaut : celle-ci serait
    /// évaluée hors de l'acteur principal.
    init(viewModel: AddPostViewModel, onCreated: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCreated = onCreated
    }

    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Pas de bouton à droite : la maquette n'en montre aucun.
                    HeaderBar(title: "Post")
                    today
                        .padding(.top, 6)
                    companies
                        .padding(.top, 14)
                    nameField
                        .padding(.top, 22)
                    contentField
                        .padding(.top, 4)
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .fontWeight(.black)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 14)
                            .padding(.horizontal, 40)
                    }
                    submit
                        .padding(.top, 62)
                }
                .padding(.bottom, 32)
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

    // MARK: Date du jour

    /// Purement indicatif : le serveur horodate lui-même à l'insertion, en UTC.
    private var today: some View {
        Text(Date.now.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year()))
            .font(.system(size: 16))
            .fontWeight(.black)
            .foregroundStyle(.beigeClear.opacity(0.45))
    }

    // MARK: Entreprise

    /// Le carrousel décale ses voisines mais ne les estompe pas : la maquette
    /// les pose à 40 %, c'est donc la carte qui s'en charge.
    @ViewBuilder
    private var companies: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(.beigeClear)
                .frame(height: 134)
        } else if viewModel.companies.isEmpty {
            Text("Aucune entreprise au référentiel. Le message partira sans.")
                .font(.system(size: 14))
                .foregroundStyle(.beige.opacity(0.7))
                .multilineTextAlignment(.center)
                .frame(height: 134)
                .padding(.horizontal, 40)
        } else {
            Carousel(
                viewModel.companies,
                index: $viewModel.companyIndex,
                sidesScaling: 1
            ) { company in
                companyCard(company)
                    .opacity(viewModel.isActive(company) ? 1 : 0.4)
            }
            .frame(height: 134)
        }
    }

    private func companyCard(_ company: Company) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.orangeCustom)
            .frame(width: 178, height: 95)
            .overlay {
                Text(company.name)
                    .font(.system(size: 36))
                    .fontWeight(.black)
                    .foregroundStyle(.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .padding(.horizontal, 12)
            }
    }

    // MARK: Champs

    private var nameField: some View {
        CustomTextField(data: $viewModel.name, label: "Nom",
                        widthTextField: 315, heightTextField: 80, fontSize: 24,
                        leadingPadding: 37, capitalization: .sentences)
    }

    /// Le message est multiligne : `CustomTextField` ne conviendrait pas, un
    /// `TextEditor` est nécessaire. Le fond du système est masqué pour laisser
    /// passer le crème, et l'invite est posée par-dessus, `TextEditor` n'en
    /// acceptant pas.
    private var contentField: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(.beigeClear)
            .frame(width: 315, height: 183)
            .overlay(alignment: .topLeading) {
                ZStack(alignment: .topLeading) {
                    if viewModel.content.isEmpty {
                        Text("Description...")
                            .font(.system(size: 24))
                            .fontWeight(.black)
                            .foregroundStyle(.accent.opacity(0.47))
                            .padding(.top, 22)
                            .padding(.leading, 37)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $viewModel.content)
                        .font(.system(size: 24))
                        .fontWeight(.black)
                        .foregroundStyle(.accent.opacity(0.47))
                        .scrollContentBackground(.hidden)
                        .padding(.top, 15)
                        .padding(.leading, 32)
                        .padding(.trailing, 20)
                        .padding(.bottom, 14)
                }
            }
            .frame(width: 315, height: 183)
    }

    // MARK: Validation

    private var submit: some View {
        ButtonAction(name: viewModel.isSaving ? "Envoi…" : "Ajouter") {
            Task {
                if await viewModel.save() {
                    onCreated()
                    dismiss()
                }
            }
        }
        .disabled(viewModel.isSaving)
        .opacity(viewModel.isSaving ? 0.6 : 1)
    }
}

#Preview {
    let viewModel = AddPostViewModel()
    viewModel.companies = [
        fakeCompany,
        Company(id: UUID(), name: "Nike", secteur: "Consommation", description: ""),
        Company(id: UUID(), name: "Tesla", secteur: "Automobile", description: "")
    ]
    viewModel.companyIndex = 1
    viewModel.hasAttemptedLoad = true

    // La pile vit dans ContentView : sans elle ici, le bouton retour n'aurait
    // rien à dépiler.
    return NavigationStack {
        AddPostView(viewModel: viewModel)
    }
    .environmentObject(AuthViewModel())
}
