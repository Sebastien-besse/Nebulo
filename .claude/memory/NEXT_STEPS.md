---
name: Next Steps
description: Priorites de Nébulo au 21 septembre 2026
type: project
---

# Prochaines étapes — Nébulo

_2026-09-21_

## P0 — dossier de conception

- [ ] Supprimer les 2 comptes au mot de passe en clair, puis ré-exporter le dump SQL
      (le dump a trois tables de retard)
- [ ] Créer le MPD, livrable exigé et absent
- [ ] Reporter les 3 associations porteuses de données sur MCD, MLD, diagramme de classes
- [ ] Checklist complète : `Conception/conception-nebulo.html`

## P0 — décisions de maquette en attente

Trois points relevés en implémentant, qu'il faut trancher avec la maquette :

- [ ] **Champ « Valeur »** (écran Ajout d'action) — saisi, non envoyé : `actions` n'a
      pas de colonne. Ajouter `price DECIMAL(10,2)`, ou retirer le champ
- [ ] **Champ « Nom »** (écran Nouveau post) — même cas, `posts` n'a pas de titre
- [ ] **Calque « Valeur » orphelin** sur la maquette Nouveau post (node `2:49`),
      sans boîte : reliquat de copie, à supprimer dans Figma

## P1 — front

- [x] Tous les écrans de la maquette
- [x] Saisie d'un dividende, absente de la maquette
- [x] Jauge d'énergie du vaisseau, décollage et célébration
- [ ] Le `+` du Forum est un ajout hors maquette : valider ou déplacer le point d'entrée
- [ ] Le badge de la fiche planète affiche le seuil ; la maquette disait « 100.90 »,
      valeur d'avant les distances réelles
- [ ] Splash : le logo est 74 points trop haut et en cadre fixe, deux contraintes de
      centrage à poser dans `LaunchScreen.storyboard`

## P2 — finitions

- [ ] Faire évoluer `users.grade` — 8 badges existent, aucune règle de passage, donc
      le carrousel des grades ne s'allume jamais
- [ ] Tests côté API (`VaporTesting`), la cible est vide
- [ ] Notification de validation de challenge
- [ ] Les réponses aux posts (`responseCount`, `GET /posts/:id/responses`) existent
      côté API mais aucun écran ne les montre
