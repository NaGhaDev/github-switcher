# GitHub Switcher

Script Bash pour gérer plusieurs profils GitHub sur Linux.

## Description

`github-switcher.sh` permet de gérer facilement plusieurs profils GitHub sur une seule machine Linux. Il prend en charge :
- La gestion multi-profils (ajouter, changer, lister, supprimer des profils).
- La création de clés SSH par profil (avec ou sans mot de passe).
- La configuration globale Git (`user.email`, `user.name`).
- L’installation automatique des dépendances (Git, SSH).
- Un guidage détaillé pour ajouter une clé SSH à GitHub.

## Prérequis

- Une connexion Internet (pour installer les dépendances et interagir avec GitHub).
- Permissions `sudo` (pour installer les dépendances).
- Un compte GitHub.

## Installation

### Option 1 : Exécution rapide via `curl`
Cette méthode exécute le script directement sans l'installer comme une commande. Exécutez :

```bash
/bin/bash -c "$(curl -fsSL <https://raw.githubusercontent.com/NaGhaDev/github-switcher/main/github-switcher.sh>)"
```

### Option 2 : Installation locale (recommandée)

Cette méthode installe le script comme une commande `gswitch` que vous pouvez exécuter depuis n’importe où.

1. Clonez ou téléchargez ce dépôt :
    
    ```bash
    git clone <https://github.com/NaGhaDev/github-switcher.git>
    cd github-switcher
    
    ```
    
2. Exécutez le script d’installation :
    
    ```bash
    chmod +x install-github-switcher.sh
    ./install-github-switcher.sh
    
    ```
    
3. Rechargez votre terminal pour appliquer les changements :
    
    ```bash
    source ~/.bashrc
    
    ```
    
4. Exécutez la commande `gswitch` depuis n’importe où :
    
    ```bash
    gswitch
    
    ```
    

## Utilisation

Le script propose un menu interactif avec les options suivantes :

1. **Ajouter un nouveau profil** : Crée un profil avec email, nom d’utilisateur, et clé SSH. Vous pouvez choisir de protéger la clé avec un mot de passe.
2. **Changer de profil** : Passe à un autre profil (met à jour Git et SSH). Si la clé est protégée, vous devrez entrer le mot de passe.
3. **Voir le profil actuel** : Affiche le profil actif, son email et son nom d’utilisateur.
4. **Lister tous les profils** : Liste les profils disponibles.
5. **Supprimer un profil** : Supprime un profil existant.
6. **Installer les dépendances** : Installe Git et SSH si nécessaire (support pour `apt`, `dnf`, `pacman`).
7. **Ajouter la clé SSH à GitHub** : Fournit des instructions détaillées pour ajouter une clé SSH à GitHub.
8. **Quitter** : Ferme le script.

## Exemple

1. Installez le script via l’option 2 (installation locale) pour utiliser la commande `gswitch`.
2. Lancez `gswitch`.
3. Sélectionnez l’option 1 pour ajouter un profil (par exemple, `NaGhaDev`, `votre-email@example.com`, `NaGhaDev`).
4. Choisissez si vous voulez protéger la clé SSH avec un mot de passe.
5. Ajoutez la clé à GitHub (option 7 ou automatiquement après création).
6. Changez de profil avec l’option 2 pour commencer à utiliser votre configuration.

## Sécurité

- **Clés SSH** : Vous pouvez protéger vos clés SSH avec un mot de passe (recommandé lors de la création d’un profil). Cela ajoute une couche de sécurité supplémentaire.
- **Sauvegarde** : Assurez-vous de sauvegarder vos clés SSH (stockées dans `~/.github-profiles/<profil>`) en lieu sûr.
- **Permissions** : Le script ajuste automatiquement les permissions des clés SSH (`chmod 600`) pour garantir leur sécurité.

## Dépannage

- **Commande `gswitch` introuvable après installation** : Assurez-vous d’avoir exécuté `source ~/.bashrc` ou redémarré votre terminal après l’installation.
- **Erreur réseau lors de l’installation des dépendances** : Vérifiez votre connexion Internet et réessayez.
- **Problèmes avec les clés SSH** : Si la connexion à GitHub échoue, vérifiez que la clé publique est bien ajoutée sur `https://github.com/settings/keys`.

## Contribuer

Si vous souhaitez contribuer, ouvrez une issue ou soumettez une pull request sur [GitHub](https://github.com/NaGhaDev/github-switcher).
