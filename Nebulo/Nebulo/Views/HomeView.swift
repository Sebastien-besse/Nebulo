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
    /// La fusée a pris la place de la jauge, à l'arrêt. Elle doit être
    /// dessinée **avant** qu'on la fasse monter : une vue qui apparaît et se
    /// déplace dans la même image n'est pas conduite d'un point à l'autre,
    /// SwiftUI l'insère directement à l'arrivée.
    @State private var isReadyToLaunch = false
    /// Les pastilles de navigation sont montées, tapies derrière le hublot.
    /// Elles doivent être dessinées **avant** de se déployer : une vue qui
    /// apparaît et bouge dans la même image n'est pas conduite d'un point à
    /// l'autre, SwiftUI l'insère directement à l'arrivée.
    @State private var isNavVisible = false
    /// L'arc est déployé.
    @State private var isNavOpen = false
    /// La fusée vibre sur place, moteurs allumés, avant de partir.
    @State private var isShaking = false
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

    /// Le centre du hublot, relevé sur l'asset du vaisseau : le trou tombe
    /// 94,7 points au-dessus du centre de son cadre, lui-même posé 170 points
    /// sous celui de l'écran. Reste 75.
    private static let portholeCenter: CGFloat = 75

    /// Diamètre du hublot, relevé sur le même asset. Le verre s'y loge
    /// exactement : un disque plus grand déborderait sur la coque, un plus
    /// petit laisserait voir le trou.
    private static let portholeDiameter: CGFloat = 70.7

    /// Rayon de l'arc de navigation. À 150, les pastilles dégagent la coque et
    /// se détachent sur le ciel ; plus court, elles mordraient sur le vert.
    private static let arcRadius: CGFloat = 150

    /// Les trois angles de l'arc, en degrés, lus dans le sens horaire depuis
    /// la droite. Le sommet au milieu, les deux autres à 50° de part et
    /// d'autre.
    private static let arcAngles: [Double] = [140, 90, 40]

    /// Combien de temps la fusée vibre avant de partir, en millisecondes.
    /// C'est le temps lent de la séquence : la poussée monte, la machine
    /// proteste, et c'est ce qui permet à la montée d'être vive sans être
    /// expédiée.
    private static let shakeDuration: Int = 900

    /// L'écart de la vibration, en points. Trois suffisent : au-delà, la
    /// fusée ne tremble plus, elle glisse de gauche à droite.
    private static let shakeAmplitude: CGFloat = 3

    /// Durée du décollage, en secondes, une fois la vibration finie. Le
    /// tremblement ayant pris le temps lent, la montée peut être franche.
    private static let launchDuration: Double = 2.4

    /// Quand la célébration prend le relais, compté depuis le début de la
    /// montée. Un peu avant la fin du vol : le voile monte pendant que la
    /// fusée achève de sortir, plutôt qu'après un temps mort.
    private static let celebrationDelay: Int = 1_700

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
        // La fusée du décollage est posée à côté de l'écran, et non dans son
        // décor : le globe y est dessiné par-dessus le vaisseau et le déborde
        // largement — 1131 points contre 420. Tout ce qui descend sous −16 est
        // masqué, or la flamme commence à +263 : il fallait monter de 278
        // points, un cinquième de la course, avant qu'elle n'apparaisse. Ici,
        // elle est allumée dès la première image.
        ZStack {
            screen
            // Le rideau : il ne se pose que lorsque l'arc est ouvert, et le
            // referme au premier toucher ailleurs. Transparent, mais il capte
            // — sans lui, l'arc resterait ouvert derrière le doigt.
            if isNavVisible {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture { closeNav() }
            }
            portholeLayer
            launchRocketLayer
        }
    }

    // MARK: Hublot et navigation

    /// Le hublot de la fusée, devenu la porte de l'application : le grade
    /// derrière le verre, et les trois écrans en arc au-dessus.
    ///
    /// Il s'efface avec la jauge au moment du décollage — le vaisseau part,
    /// son hublot ne reste pas en l'air.
    private var portholeLayer: some View {
        ZStack {
            // L'arc est dessiné avant le hublot, donc dessous : au repos les
            // pastilles sont tapies derrière lui, à l'échelle 0,4, et il les
            // couvre entièrement. C'est ce qui permet de les monter à l'avance
            // sans qu'on les voie.
            navArc
            portholeButton
        }
        .offset(y: Self.portholeCenter)
        .opacity(isReadyToLaunch ? 0 : 1)
        .allowsHitTesting(!isReadyToLaunch)
    }

    /// Le verre du hublot, et le grade au travers.
    private var portholeButton: some View {
        Button { toggleNav() } label: {
            ZStack {
                if let image = viewModel.gradeImage {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                }
            }
            .frame(width: Self.portholeDiameter, height: Self.portholeDiameter)
            // Le même verre que les pastilles, en rond : le décor passe au
            // travers au lieu d'être masqué.
            .glassEffect(
                .clear.tint(Color.white.opacity(0.08)),
                in: .circle
            )
        }
        .accessibilityLabel(
            viewModel.grade?.current.map { "Grade \($0.name). Ouvrir la navigation." }
            ?? "Ouvrir la navigation"
        )
        .accessibilityAddTraits(isNavOpen ? .isSelected : [])
    }

    private var navArc: some View {
        ZStack {
            arcButton(0, icon: "IconeActions", label: "Portefeuille") { route = .portfolio }
            arcButton(1, icon: "IconeProfil", label: "Profil") { route = .profil }
            arcButton(2, icon: "IconeForum", label: "Forum") { route = .forum }
        }
    }

    /// Une pastille de l'arc. Fermée, elle est au centre et minuscule ;
    /// ouverte, elle rejoint son angle. Les trois sortent l'une après l'autre,
    /// à cinquante millisecondes d'intervalle — ensemble, elles se liraient
    /// comme un bloc qui s'écarte plutôt que comme un éventail.
    private func arcButton(
        _ index: Int,
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        let radians = Self.arcAngles[index] * .pi / 180
        let x = isNavOpen ? Self.arcRadius * cos(radians) : 0
        let y = isNavOpen ? -Self.arcRadius * sin(radians) : 0

        return ButtonNav(
            btnNav: {
                closeNav()
                action()
            },
            icon: icon,
            isRound: true
        )
        .scaleEffect(isNavOpen ? 1 : 0.4)
        .offset(x: x, y: y)
        .animation(
            reduceMotion
            ? nil
            : .spring(response: 0.42, dampingFraction: 0.72)
                .delay(isNavOpen ? Double(index) * 0.05 : 0),
            value: isNavOpen
        )
        .accessibilityLabel(label)
        .accessibilityHidden(!isNavOpen)
    }

    // MARK: Ouverture de l'arc

    private func toggleNav() {
        isNavOpen ? closeNav() : openNav()
    }

    private func openNav() {
        guard !reduceMotion else {
            isNavVisible = true
            isNavOpen = true
            return
        }
        // Deux temps, séparés par une image : les pastilles sont montées
        // derrière le hublot, puis elles se déploient. Les réunir revient à
        // les faire apparaître déjà en place, sans mouvement.
        isNavVisible = true
        Task {
            try? await Task.sleep(for: .milliseconds(40))
            isNavOpen = true
        }
    }

    private func closeNav() {
        guard isNavVisible else { return }
        isNavOpen = false
        // Démontées seulement une fois rentrées, sans quoi elles
        // disparaîtraient en chemin.
        Task {
            try? await Task.sleep(for: .milliseconds(reduceMotion ? 0 : 420))
            if !isNavOpen { isNavVisible = false }
        }
    }

    /// Le décollage, en avant de tout : la fusée s'éloigne du sol, elle se
    /// rapproche de l'œil. Invisible au repos, posée au même endroit que la
    /// jauge — les 550 de la pile du décor moins les 380 de la jauge.
    private var launchRocketLayer: some View {
        launchRocket
            .opacity(isReadyToLaunch ? 1 : 0)
            // La vibration : un aller-retour serré, posé sous la montée pour
            // qu'ils ne se gênent pas. L'animation retombe à nil quand la
            // vibration cesse, ce qui recentre la fusée d'un coup — un
            // `repeatForever` qu'on laisse se dénouer continuerait d'osciller.
            .offset(x: isShaking ? Self.shakeAmplitude : -Self.shakeAmplitude)
            .animation(
                isShaking && !reduceMotion
                ? .linear(duration: 0.05).repeatForever(autoreverses: true)
                : nil,
                value: isShaking
            )
            .offset(y: 170)
            // La montée : lente au départ, puis emballée, comme une poussée
            // qui vainc l'inertie. 1500 points suffisent à sortir du cadre.
            .offset(y: isLaunching ? -1500 : 0)
            .animation(
                reduceMotion ? nil : .easeIn(duration: Self.launchDuration),
                value: isLaunching
            )
            .allowsHitTesting(false)
    }

    private var screen: some View {
        // Les contrôles portent la mise en page : eux seuls doivent se caler
        // sur l'écran. Le décor passe en `background` avec une taille fixe de
        // 1131 — celle que lui donnait le ZStack d'origine — et déborde de
        // part et d'autre comme avant, sans influencer la position du reste.
        VStack(spacing: 0) {
            totalCard
            // La rangée de boutons a quitté le haut de l'écran pour l'arc du
            // hublot : le challenge récupère la place et remonte d'une
            // centaine de points. Pas jusqu'en haut pour autant — collé sous
            // la carte du total il y pesait, alors que l'arc laisse près de
            // deux cents points libres sous lui.
            challenge
                .padding(.top, 90)
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
        // Trois temps, chacun dans sa propre image : la fusée remplace la
        // jauge, elle vibre, elle part. Réunir les deux premiers revient à la
        // faire disparaître — une vue qui apparaît et bouge dans la même image
        // n'est pas conduite d'un point à l'autre.
        // Le hublot s'en va avec le vaisseau : l'arc ne peut pas rester
        // ouvert au-dessus du vide.
        closeNav()
        isReadyToLaunch = true
        Task {
            try? await Task.sleep(for: .milliseconds(80))
            isShaking = true

            try? await Task.sleep(for: .milliseconds(Self.shakeDuration))
            // La vibration s'arrête net et la fusée part : son animation vaut
            // nil dès que `isShaking` est faux, la fusée se recentre donc sans
            // transition au lieu de revenir mollement.
            isShaking = false
            // Une image d'intervalle, comme entre l'apparition et la montée :
            // deux changements de géométrie dans la même image, et celui qui
            // porte une animation nulle emporte l'autre — la fusée sautait
            // hors du cadre au lieu de monter.
            try? await Task.sleep(for: .milliseconds(40))
            isLaunching = true

            try? await Task.sleep(for: .milliseconds(Self.celebrationDelay))
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
            withTransaction(transaction) {
                isLaunching = false
                isShaking = false
                isReadyToLaunch = false
            }
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

    /// La fusée du décollage. Elle ne paraît qu'au franchissement d'un seuil,
    /// le temps du vol, puis rend sa place à la jauge.
    ///
    /// Asset distinct du vaisseau-jauge : celui-ci est une silhouette à
    /// remplir, muette une fois pleine. Celle-là a sa flamme allumée, et ne
    /// sert qu'à ça.
    private var launchRocket: some View {
        Image("rocket_new_planet")
            .resizable()
            .scaledToFit()
            .frame(width: 420.96, height: 420.96)
            .accessibilityHidden(true)
    }

    /// Le vaisseau survole la planète la plus lointaine déjà atteinte : la
    /// Terre au départ, Neptune au bout du voyage.
    private var spaceship: some View {
        ZStack {
            // La jauge reste derrière le globe, qui lui mange le bas : c'est
            // ce qui la fait reposer sur la planète plutôt que flotter devant.
            energyGauge
                .opacity(isReadyToLaunch ? 0 : 1)
                .offset(y: -380)
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

            // La fusée du décollage vit **devant** le globe, et de façon
            // permanente : invisible au repos, posée au même endroit que la
            // jauge. Elle ne peut pas être derrière, le globe masquerait sa
            // flamme le temps qu'elle s'en dégage — 278 points, un cinquième
            // de la course. Et un `zIndex` qui bascule ne marche pas non plus :
            // changer l'ordre d'une pile réinsère la vue, qui réapparaît
            // directement à son point d'arrivée, sans monter.
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
