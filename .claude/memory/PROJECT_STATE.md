---
name: Project State
description: Etat d'avancement de Nébulo au 21 septembre 2026
type: project
---

# État du projet — Nébulo

_2026-09-21_

## Backend — complet

Auth, profil, actions, dividendes, planètes, challenges, forum. Build sans warning,
chaque domaine testé de bout en bout contre la base réelle. 11 tables, 2 triggers,
1 fonction stockée, 1 procédure. Détail dans `CDA/docs/API.md`.

## Application iOS — tous les écrans branchés

Onze écrans, tous sur le patron `View → ViewModel → Service → Repository → APIService` :
Accueil, Authentification, Inscription, Profil, Portefeuille, Ajout d'action, Saisie
d'un dividende, Forum, Nouveau post, Société, Fiche planète.

**Aucune donnée en dur ne subsiste.** Le dernier écran de la maquette a été livré le
20 septembre, et celui de saisie d'un dividende — absent de la maquette — le 21.

Le parcours complet tourne contre l'API réelle : inscription, ajout d'une action,
saisie d'un dividende, montée de l'énergie, déblocage d'une planète, publication d'un
message et vote sur le forum.

`HeaderBar` porte l'en-tête de tous les écrans. `APIService` sait faire `get`,
`getOptional` (pour les `204`), `post`, `put` et `delete`.

## Gamification à l'écran

Le vaisseau de l'accueil fait jauge d'énergie vers la planète suivante. Un seuil
franchi déclenche son décollage, puis la célébration qui nomme la planète. La fiche
d'une planète se feuillette sur les huit ; celles hors de portée ont leur nom flouté
et affichent l'énergie manquante.

## Reste à faire

Voir `NEXT_STEPS.md`, et `CDA/docs/EVOLUTIONS.md` section « Écarts ouverts ».
