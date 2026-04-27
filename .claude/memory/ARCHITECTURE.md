---
name: Architecture
description: Tech stack, folder structure, and key flows for Nébulo
type: project
---

# Architecture — Nébulo

## Stack
- **Language**: Swift
- **UI**: SwiftUI
- **Pattern**: MVVM (ViewModels not yet created)
- **Persistence**: TBD (CoreData / SwiftData / API)
- **Platform**: iOS

## Folder Structure
```
Nebulo/Nebulo/
├── Assets.xcassets/         # Images, colors (accent, orangeCustom)
├── Components/              # Reusable UI components
│   ├── BadgeCard.swift
│   ├── ButtonAction.swift
│   ├── ButtonNav.swift
│   ├── CardCarouselPost.swift
│   ├── CorporateCard.swift
│   ├── CustomTextField.swift
│   ├── InvestCard.swift
│   ├── PlanetCard.swift
│   ├── PlanetDetail.swift
│   └── TitleCard.swift
├── Models/
│   ├── Badge.swift
│   ├── Planet.swift
│   └── Post.swift
├── Views/
│   └── AuthentificationView.swift
├── ContentView.swift
├── NebuloApp.swift
└── LaunchScreen.storyboard
```

## Key Entities (from README)
- Actions (stocks tracked by user)
- Positions (quantity held per stock)
- Dividendes (dividend history)
- Challenges (gamification goals)
- Planètes (galaxy progression)
- Énergie (points from dividends)
- Profil (user data)
- Forum (company descriptions)
- Post (user comments on stocks)

## Key Flow
1. App launch → LaunchScreen → AuthentificationView
2. Login → (TBD) Main dashboard with portfolio
3. Dividends received → energy generated → planets unlocked
