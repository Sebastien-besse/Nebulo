---
name: Project State
description: Etat d'avancement de Nébulo au 14 septembre 2026
type: project
---

# État du projet — Nébulo

_2026-09-14_

## Backend — complet

Auth, profil, actions, dividendes, planètes, challenges, forum. Build sans warning,
chaque domaine testé de bout en bout contre la base réelle. 11 tables, 2 triggers,
1 fonction stockée, 1 procédure. Détail dans `CDA/docs/API.md`.

## Application iOS — authentification seule

Seule la pile Auth est branchée. `TokenStore` utilise le trousseau, avec 4 tests qui
passent dans le simulateur. `HomeView` reste une maquette statique. Aucun
`NavigationStack` dans le projet.

## Reste à faire

Voir `CDA/docs/EVOLUTIONS.md`, section « Écarts ouverts », et la checklist de
conception `CDA/Conception/conception-nebulo.html`.
