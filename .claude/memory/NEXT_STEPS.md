---
name: Next Steps
description: Prioritized roadmap for Nébulo
type: project
---

# Next Steps — Nébulo

## Priority 1 — Core App Shell
- [ ] Fix `CustomTextField` to use `@Binding<String>` instead of plain `String`
- [ ] Replace `sleep(2)` in ContentView with a proper splash/launch screen approach
- [ ] Create main `TabView` or `NavigationStack` for post-login navigation
- [ ] Scaffold ViewModels (at minimum `AuthViewModel`)

## Priority 2 — Authentication
- [ ] Implement real login/signup logic
- [ ] Decide on backend: local (SwiftData/CoreData) vs remote API

## Priority 3 — Portfolio & Dividends
- [ ] Build stock/action list view
- [ ] Add dividend entry form
- [ ] Display monthly and annual income summaries

## Priority 4 — Gamification
- [ ] Energy system: calculate points from dividends
- [ ] Galaxy view with planet cards and unlock progression
- [ ] Challenges screen

## Priority 5 — Community
- [ ] Forum / post list view using `Post` model
- [ ] `CorporateCard` and `CardCarouselPost` integration
