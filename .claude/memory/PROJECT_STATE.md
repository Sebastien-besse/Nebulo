---
name: Project State
description: Current phase, completed work, and known issues for Nébulo
type: project
---

# Project State — Nébulo

## Phase
Early development — Authentication UI built, core components scaffolded, no navigation or backend yet.

## Done
- Initial Xcode project setup (SwiftUI + MVVM)
- Assets added (Logo-Nebulo, RocketConnexion, custom colors)
- Shared UI components: BadgeCard, ButtonAction, ButtonNav, CardCarouselPost, CorporateCard, CustomTextField, InvestCard, PlanetCard, PlanetDetail, TitleCard
- Models: Planet, Badge, Post
- AuthentificationView (email/password form with logo and rocket button — no real auth logic yet)
- LaunchScreen storyboard

## Remaining
- Authentication logic (no real login/signup flow yet)
- Main app navigation (TabView or NavigationStack post-login)
- Dashboard / portfolio view
- Dividend tracking (add, history, monthly/annual totals)
- Energy system (points from dividends)
- Galaxy/planet progression screen
- Challenges system
- Community forum
- Backend / persistence (CoreData, SwiftData, or API — TBD)
- ViewModels (none created yet)

## Known Issues
- `CustomTextField` takes `data` as a non-binding String — likely needs `@Binding` for real use
- `ContentView` wraps `AuthentificationView` with a `sleep(2)` — likely placeholder for splash screen
- No ViewModel layer yet despite MVVM intent
