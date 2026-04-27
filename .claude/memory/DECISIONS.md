---
name: Decisions
description: Conventions and architectural choices for Nébulo
type: project
---

# Decisions — Nébulo

## Language & UI
- **Swift + SwiftUI** chosen for native iOS experience and modern declarative UI
- **MVVM** pattern intended — ViewModels not yet created but planned

## Naming
- Components are named by their visual role (e.g., `PlanetCard`, `BadgeCard`, `ButtonNav`)
- Views go in `Views/`, reusable UI in `Components/`, data models in `Models/`

## Styling
- Custom colors defined in Assets: `accent` (background), `orangeCustom` (CTA)
- Space/cosmic visual theme throughout

## Auth
- Login form uses email + password
- Button is a rocket image inside an orange circle — fits the space theme
- No real auth logic implemented yet (just `print("connecter")`)
