#!/bin/bash

# install-github-switcher.sh
# Ce script installe github-switcher.sh pour qu'il soit utilisable comme une commande.

set -e

# Chemin vers le dossier contenant le script source
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Nom du script source
SOURCE_SCRIPT="$SCRIPT_DIR/github-switcher.sh"

# Dossier d'installation
BIN_DIR="$HOME/.local/bin"
BASHRC="$HOME/.bashrc"

# Nom de la commande installée (sans l'extension .sh)
DEST_NAME="gswitch"
DEST_PATH="$BIN_DIR/$DEST_NAME"

# Vérifier si le script source existe
if [ ! -f "$SOURCE_SCRIPT" ]; then
    echo "Erreur : $SOURCE_SCRIPT introuvable. Assurez-vous que github-switcher.sh est dans le même dossier que ce script."
    exit 1
fi

# Créer le dossier d'installation s'il n'existe pas
echo "==> Création du dossier $BIN_DIR (si inexistant)"
mkdir -p "$BIN_DIR" || {
    echo "Erreur : Impossible de créer $BIN_DIR. Vérifiez les permissions."
    exit 1
}

# Ajouter $HOME/.local/bin dans le PATH si nécessaire
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo "==> Ajout de $HOME/.local/bin au PATH dans $BASHRC"
    echo -e "\n# Ajout de ~/.local/bin au PATH pour gswitch" >> "$BASHRC"
    echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$BASHRC"
    echo "Ligne ajoutée dans $BASHRC. Pensez à exécuter 'source ~/.bashrc' ou à redémarrer votre terminal."
else
    echo "==> $HOME/.local/bin est déjà dans votre PATH."
fi

# Installer le script
echo "==> Installation de $(basename "$SOURCE_SCRIPT") en tant que $DEST_NAME"
cp "$SOURCE_SCRIPT" "$DEST_PATH" || {
    echo "Erreur : Impossible de copier le script vers $DEST_PATH. Vérifiez les permissions."
    exit 1
}
chmod +x "$DEST_PATH" || {
    echo "Erreur : Impossible de rendre $DEST_PATH exécutable. Vérifiez les permissions."
    exit 1
}

# Vérifier que l'installation a réussi
if command -v "$DEST_NAME" >/dev/null 2>&1; then
    echo "==> Installation terminée avec succès !"
    echo "Vous pouvez maintenant exécuter 'gswitch' depuis n'importe où."
else
    echo "==> Installation terminée, mais la commande 'gswitch' n'est pas accessible."
    echo "Assurez-vous que $BIN_DIR est dans votre PATH. Exécutez 'source ~/.bashrc' ou redémarrez votre terminal."
fi