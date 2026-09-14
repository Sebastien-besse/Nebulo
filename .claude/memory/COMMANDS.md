---
name: Commands
description: Commandes de developpement pour Nébulo
type: project
---

# Commandes — Nébulo

## API
```bash
cd NebuloAPI
swift build
swift run NebuloAPI serve --hostname 127.0.0.1 --port 8080
```

## Application iOS
```bash
open Nebulo/Nebulo/Nebulo.xcodeproj
xcodebuild -project Nebulo/Nebulo/Nebulo.xcodeproj -scheme Nebulo \
  -destination 'platform=iOS Simulator,name=iPhone 16e' test
```
Le scheme ne propose que des simulateurs iOS 26.2.

## Base
```bash
/Applications/XAMPP/xamppfiles/bin/mysql -u root nebulo_db
```
MySQL démarre via XAMPP. Le serveur n'écoute qu'en IPv4 : viser `127.0.0.1`, jamais
`localhost`, depuis le simulateur.
