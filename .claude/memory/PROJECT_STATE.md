---
name: Project State
description: Etat d'avancement de Nébulo au 15 septembre 2026
type: project
---

# État du projet — Nébulo

_2026-09-15_

## Backend — complet

Auth, profil, actions, dividendes, planètes, challenges, forum. Build sans warning,
chaque domaine testé de bout en bout contre la base réelle. 11 tables, 2 triggers,
1 fonction stockée, 1 procédure. Détail dans `CDA/docs/API.md`.

## Application iOS — authentification et profil

`NavigationStack` posé dans `ContentView`, destinations décrites par `HomeRoute`.

L'écran Profil consomme `GET /users/me` et `GET /planets` en parallèle, et enregistre
par `PUT /users/me`. Les quatre champs s'éditent dans `EditFieldDialog`, un modal aux
couleurs de l'app. Les huit planètes s'affichent, verrouillées avec un cadenas tant que
leur seuil n'est pas atteint.

`TokenStore` utilise le trousseau, avec 4 tests qui passent dans le simulateur.
`HomeView` affiche encore un montant en dur ; ses boutons Actions et Forum sont inertes.

## Reste à faire

Voir `CDA/docs/EVOLUTIONS.md`, section « Écarts ouverts », et la checklist de
conception `CDA/Conception/conception-nebulo.html`.
