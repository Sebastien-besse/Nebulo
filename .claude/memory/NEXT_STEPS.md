---
name: Next Steps
description: Priorites de Nébulo au 14 septembre 2026
type: project
---

# Prochaines étapes — Nébulo

_2026-09-15_

## P0 — dossier de conception
- [ ] Supprimer les 2 comptes au mot de passe en clair, puis ré-exporter le dump SQL
- [ ] Créer le MPD, livrable exigé et absent
- [ ] Reporter les 3 associations porteuses de données sur MCD, MLD, diagramme de classes
- [ ] Checklist complète : `Conception/conception-nebulo.html`

## P1 — brancher le front
- [x] `NavigationStack` et routeur (`HomeRoute`)
- [x] Écran Profil, branché sur `/users/me` et `/planets`
- [ ] Remplacer le montant en dur de `HomeView` par `GET /dividends/summary`
- [ ] Brancher le bloc Challenges sur `GET /challenges/current`
- [ ] Écrans actions, dividendes, galaxie, forum

## P2 — finitions
- [ ] Faire évoluer `users.grade` — 8 badges existent, aucune règle de passage
- [ ] Tests côté API (`VaporTesting`), la cible est vide
- [ ] Notification de validation de challenge
