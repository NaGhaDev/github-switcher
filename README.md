# GitHub Switcher

Script Bash pour gérer plusieurs profils GitHub sur Linux.

## Description

`github-switcher.sh` permet de gérer facilement plusieurs profils GitHub sur une seule machine Linux. Il prend en charge :
- La gestion multi-profils (ajouter, changer, lister, supprimer des profils).
- La création de clés SSH par profil.
- La configuration globale Git (`user.email`, `user.name`).
- L’installation automatique des dépendances (Git, SSH).
- Un guidage détaillé pour ajouter une clé SSH à GitHub.

## Prérequis

- Une connexion Internet (pour installer les dépendances et interagir avec GitHub).
- Permissions `sudo` (pour installer les dépendances).
- Un compte GitHub.

## Installation

Exécutez la commande suivante pour télécharger et lancer le script directement depuis GitHub :

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/NaGhaDev/github-switcher/main/github-switcher.sh)"