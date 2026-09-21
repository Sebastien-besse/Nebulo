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
    case portfolio
    case forum
}

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: HomeViewModel
    @State private var route: HomeRoute?
    /// La fiche d'une planète se présente par-dessus l'accueil plutôt que
    /// de s'y empiler : on en revient, on n'y progresse pas.
    @State private var selectedPlanet: Planet?
    /// Passe à vrai au premier affichage et n'en revient jamais : c'est ce
    /// changement, et lui seul, qui déclenche la rotation perpétuelle du ciel.
    @State private var isRotating = false
    /// Le vaisseau quitte l'écran. Déclenché par un seuil franchi.
    @State private var isLaunching = false
    /// La célébration n'arrive qu'une fois le vaisseau sorti du cadre.
    @State private var showCelebration = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Durée d'un tour complet du ciel, en secondes. Une étoile met alors une
    /// vingtaine de secondes à traverser l'écran : assez lent pour qu'on ne la
    /// surprenne pas en train de bouger, assez vif pour que le ciel ne paraisse
    /// pas figé si on s'y attarde.
    private static let starfieldTurn: Double = 240

    private static let starfieldSize = CGSize(width: 334.25, height: 539.76)

    /// Nombre d'exemplaires du champ d'étoiles répartis sur la couronne. À ce
    /// rythme le motif se répète tous les 26°, soit moins que la largeur de
    /// l'écran vue depuis le centre de la planète : il n'y a jamais de trou.
    private static let starfieldCopies = 14

    /// Distance entre le centre de l'écran et celui du globe. C'est l'offset
    /// que `spaceship` applique déjà à la Terre : les deux doivent rester
    /// d'accord, sinon les étoiles n'orbitent plus autour de la bonne chose.
    private static let planetCenterOffset: CGFloat = 550

    /// Le pivot, exprimé dans l'espace du champ d'étoiles. Il tombe sous son
    /// bord inférieur, d'où l'ordonnée supérieure à 1.
    private static var planetAnchor: UnitPoint {
        UnitPoint(x: 0.5, y: 0.5 + planetCenterOffset / starfieldSize.height)
    }

    /// Le ViewModel est injecté, sans valeur par défaut : celle-ci serait
    /// évaluée hors de l'acteur principal. C'est aussi ce qui permet aux
    /// previews d'afficher l'écran rempli, sans jeton ni serveur.
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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
        // De retour d'un écran poussé. L'accueil est la racine de la pile : il
        // reste vivant pendant la navigation, donc son `task` ne se rejoue pas.
        // Or un dividende a pu être saisi entre-temps, et le montant comme la
        // planète sous la fusée en dépendent.
        .onChange(of: route) { _, destination in
            if destination == nil {
                Task { await viewModel.load() }
            }
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                starfield
                spaceship
            }
            .frame(width: 1131, height: 1131)
        }
        .background(.accent)
        // L'écran porte son propre en-tête : la barre système ferait doublon.
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $route) { destination in
            switch destination {
            case .profil:
                ProfilView(viewModel: ProfileViewModel())
            case .portfolio:
                PortfolioView(viewModel: PortfolioViewModel())
            case .forum:
                ForumView(viewModel: ForumViewModel())
            }
        }
        // Un seuil vient d'être franchi. En surimpression plutôt qu'en
        // présentation modale : la célébration doit tomber sur le décor de
        // l'accueil, pas le remplacer.
        .overlay {
            if showCelebration, let planet = viewModel.justUnlocked {
                PlanetUnlockedOverlay(planet: planet) { endCelebration() }
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.25), value: showCelebration)
        .onChange(of: viewModel.justUnlocked) { _, planet in
            if planet != nil { startLaunch() }
        }
        // La planète est déjà en mémoire, chargée avec le tableau de bord :
        // rien à relire au serveur.
        .fullScreenCover(item: $selectedPlanet) { planet in
            PlanetDetailView(
                planets: viewModel.planets,
                selected: planet,
                energy: viewModel.summary?.energy ?? 0
            )
        }
    }

    // MARK: Décollage

    /// Le vaisseau part d'abord, la planète se dévoile ensuite. L'ordre porte
    /// le sens : le décollage raconte le franchissement, la célébration le
    /// nomme. Les montrer ensemble reviendrait à n'en montrer aucun.
    private func startLaunch() {
        guard !reduceMotion else {
            showCelebration = true
            return
        }
        isLaunching = true
        Task {
            try? await Task.sleep(for: .milliseconds(1300))
            showCelebration = true
        }
    }

    private func endCelebration() {
        showCelebration = false
        viewModel.justUnlocked = nil
        // Le vaisseau reprend son poste une fois le voile retombé, et sans
        // animation : le voir redescendre défferait le décollage.
        Task {
            try? await Task.sleep(for: .milliseconds(320))
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { isLaunching = false }
        }
    }

    // MARK: Décor

    /// Le ciel défile autour de la planète : les étoiles sortent par la droite,
    /// passent derrière le globe et reviennent par la gauche. La planète et la
    /// fusée ne bougent pas — c'est le point de vue de quelqu'un posé au sol.
    ///
    /// Le pivot n'est pas le centre de l'écran mais **celui de la planète**,
    /// 550 points plus bas. Tourner autour de son propre centre faisait pivoter
    /// l'image sur place ; tourner autour du globe la fait orbiter.
    ///
    /// Une seule image ne suffit pas : passé un quart de tour elle se retrouve
    /// hors champ, et le ciel se vide pendant les trois quarts du cycle. Elle
    /// est donc répétée en couronne, chaque exemplaire décalé d'un cran, si
    /// bien qu'au moment où l'un sort à droite le suivant entre à gauche.
    private var starfield: some View {
        ZStack {
            ForEach(0..<Self.starfieldCopies, id: \.self) { index in
                Image("BackgroundHome")
                    .resizable()
                    .scaledToFill()
                    .frame(width: Self.starfieldSize.width, height: Self.starfieldSize.height)
                    .allowsHitTesting(false)
                    // Deux exemplaires voisins ne doivent pas se lire comme la
                    // même image recopiée : les tailles alternent légèrement.
                    .scaleEffect(index.isMultiple(of: 2) ? 1 : 0.88)
                    .rotationEffect(
                        .degrees(Double(index) * 360 / Double(Self.starfieldCopies)),
                        anchor: Self.planetAnchor
                    )
            }
        }
        .rotationEffect(.degrees(isRotating ? 360 : 0), anchor: Self.planetAnchor)
        // `animation(_:value:)` plutôt qu'un `withAnimation` dans `onAppear` :
        // l'écran se redessine à chaque publication du ViewModel — chargement,
        // montant, challenge — et une animation lancée impérativement se ferait
        // interrompre au passage. Ici elle est attachée à cette vue et à ce seul
        // changement d'état.
        .animation(
            reduceMotion
            ? nil
            : .linear(duration: Self.starfieldTurn).repeatForever(autoreverses: false),
            value: isRotating
        )
        .onAppear { isRotating = true }
    }

    /// Le vaisseau fait jauge : il se remplit de vert à mesure qu'on approche
    /// de la planète suivante.
    ///
    /// Les trois assets sont la même silhouette — `Starship` toute blanche,
    /// `StarshipEnergy` toute verte, `Starship50` à moitié. Plutôt que de
    /// choisir entre trois paliers, la verte est superposée à la blanche et
    /// masquée par le bas : le remplissage devient continu.
    private var energyGauge: some View {
        ZStack {
            Image("Starship")
                .resizable()
                .scaledToFill()
                .frame(width: 420.96, height: 420.96)

            Image("StarshipEnergy")
                .resizable()
                .scaledToFill()
                .frame(width: 420.96, height: 420.96)
                .mask(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 420.96 * viewModel.energyProgress)
                }
        }
        // Le niveau monte sous les yeux au retour d'une saisie, au lieu de
        // sauter d'un cran.
        .animation(
            reduceMotion ? nil : .easeOut(duration: 0.8),
            value: viewModel.energyProgress
        )
        .accessibilityLabel(
            "Vaisseau chargé à \(Int(viewModel.energyProgress * 100)) pour cent vers la prochaine planète."
        )
    }

    /// Le vaisseau survole la planète la plus lointaine déjà atteinte : la
    /// Terre au départ, Neptune au bout du voyage.
    private var spaceship: some View {
        ZStack {
            energyGauge
                .offset(y: -380)
                // La montée : lente au départ, puis emballée, comme une poussée
                // qui vainc l'inertie. 1500 points suffisent à sortir du cadre.
                .offset(y: isLaunching ? -1500 : 0)
                .animation(
                    reduceMotion ? nil : .easeIn(duration: 1.3),
                    value: isLaunching
                )
                .allowsHitTesting(false)

            Image(viewModel.currentPlanetImage)
                .resizable()
                .scaledToFill()
                .frame(width: 1131)
                // Le globe est un disque dans un cadre carré : sans cette
                // forme, ses angles vides avaleraient les touchers destinés au
                // ciel qui l'entoure.
                .contentShape(Circle())
                .onTapGesture { selectedPlanet = viewModel.currentPlanet }
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(
                    viewModel.currentPlanet.map { "\($0.name), atteinte. Toucher pour voir sa fiche." }
                    ?? "Planète"
                )
        }
        .offset(y: 550)
    }

    // MARK: Contenu

    /// Le cumul de toujours des dividendes encaissés. Les cotes viennent de la
    /// maquette : 146 sur 58, rayon 14, texte de 32.
    private var totalCard: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(.beigeClear)
            .frame(width: 146, height: 58)
            .overlay {
                Text(viewModel.totalLabel)
                    .font(.system(size: 32))
                    .fontWeight(.black)
                    .foregroundStyle(.accent.opacity(0.47))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 12)
            }
    }

    /// Les trois accès de la maquette : actions à gauche, profil et forum à
    /// droite, plaqués contre les bords.
    private var navigation: some View {
        VStack(alignment: .trailing, spacing: 16) {
            HStack {
                ButtonNav(btnNav: { route = .portfolio }, icon: "IconeActions")
                Spacer()
                ButtonNav(btnNav: { route = .profil }, icon: "IconeProfil")
            }
            ButtonNav(btnNav: { route = .forum }, icon: "IconeForum")
        }
    }

    /// Lire le challenge courant le fait avancer : le serveur recalcule la
    /// progression, crédite l'énergie si l'objectif est atteint et tire le
    /// suivant. L'accueil est donc aussi ce qui valide les challenges.
    private var challenge: some View {
        VStack(spacing: 4) {
            Text("Challenges")
                .font(.system(size: 20))
                .fontWeight(.black)
                .foregroundStyle(.yellowCustom)
            Text(challengeLabel)
                .font(.system(size: 20))
                .fontWeight(.medium)
                .foregroundStyle(.beige)
                .opacity(0.8)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
    }

    private var challengeLabel: String {
        if let challenge = viewModel.challenge {
            return challenge.description
        }
        // Le pool est épuisé, ou rien n'a encore été chargé : les deux laissent
        // le challenge nil, mais ne se disent pas de la même façon.
        return viewModel.hasLoaded
            ? "Tous les challenges sont terminés."
            : (viewModel.errorMessage ?? "Chargement…")
    }
}

#Preview {
    // La pile vit dans ContentView : sans elle ici, la navigation vers Profil
    // n'aurait nulle part où pousser.
    let viewModel = HomeViewModel()
    viewModel.summary = fakeSummary
    viewModel.challenge = fakeChallenge
    viewModel.planets = fakePlanets
    viewModel.hasLoaded = true
    viewModel.hasAttemptedLoad = true

    return NavigationStack {
        HomeView(viewModel: viewModel)
    }
    .environmentObject(AuthViewModel())
}
