#!/bin/bash

# Définition des couleurs pour un meilleur affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Dossier de configuration
CONFIG_DIR="$HOME/.github-profiles"
CURRENT_PROFILE_FILE="$CONFIG_DIR/current_profile"

# Variable pour activer/désactiver la vérification des dépendances au démarrage
CHECK_DEPS_ON_START=true

# Création du dossier de configuration s'il n'existe pas
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR" || {
        echo -e "${RED}Erreur : Impossible de créer $CONFIG_DIR. Vérifiez les permissions.${NC}"
        exit 1
    }
fi

# Fonction pour détecter le gestionnaire de paquets
detect_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Fonction pour installer les dépendances (Git et SSH)
install_dependencies() {
    echo -e "${BLUE}=== Installation des dépendances ===${NC}"
    
    # Vérifier si Git et SSH sont déjà installés
    if command -v git >/dev/null 2>&1 && command -v ssh >/dev/null 2>&1; then
        echo -e "${GREEN}Git et SSH sont déjà installés.${NC}"
        return 0
    fi

    # Vérifier la connexion réseau
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        echo -e "${RED}Erreur : Connexion réseau requise pour installer les dépendances.${NC}"
        echo "Solution : Vérifiez votre connexion Internet et réessayez."
        return 1
    fi

    # Détecter le gestionnaire de paquets
    pkg_manager=$(detect_package_manager)
    case $pkg_manager in
        apt)
            echo "Mise à jour des dépôts..."
            sudo apt-get update || {
                echo -e "${RED}Erreur : Échec de la mise à jour des dépôts. Vérifiez vos permissions ou votre connexion.${NC}"
                return 1
            }
            sudo apt-get install -y git openssh-client || {
                echo -e "${RED}Erreur : Échec de l'installation de Git ou SSH. Vérifiez vos dépôts.${NC}"
                return 1
            }
            ;;
        dnf)
            sudo dnf install -y git openssh-clients || {
                echo -e "${RED}Erreur : Échec de l'installation de Git ou SSH. Vérifiez vos dépôts.${NC}"
                return 1
            }
            ;;
        pacman)
            sudo pacman -Sy --noconfirm git openssh || {
                echo -e "${RED}Erreur : Échec de l'installation de Git ou SSH. Vérifiez vos dépôts.${NC}"
                return 1
            }
            ;;
        *)
            echo -e "${RED}Erreur : Gestionnaire de paquets non supporté ($pkg_manager).${NC}"
            echo "Solution : Installez Git et SSH manuellement pour votre distribution."
            return 1
            ;;
    esac

    # Vérifier l'installation
    if command -v git >/dev/null 2>&1 && command -v ssh >/dev/null 2>&1; then
        echo -e "${GREEN}Git et SSH installés avec succès !${NC}"
        return 0
    else
        echo -e "${RED}Erreur : Échec de l'installation des dépendances. Vérifiez les messages ci-dessus.${NC}"
        return 1
    fi
}

# Fonction pour guider l’ajout de la clé SSH à GitHub
guide_ssh_key() {
    echo -e "${BLUE}=== Ajout de la clé SSH à GitHub ===${NC}"
    
    # Lister uniquement les dossiers (exclure les fichiers comme current_profile)
    profiles=($(find "$CONFIG_DIR" -maxdepth 1 -type d -not -path "$CONFIG_DIR" -exec basename {} \; 2>/dev/null))
    if [ ${#profiles[@]} -eq 0 ]; then
        echo -e "${RED}Aucun profil trouvé. Créez-en un avec l’option 1.${NC}"
        return 1
    fi

    echo "Profils disponibles :"
    for i in "${!profiles[@]}"; do
        echo "$((i+1)). ${profiles[$i]}"
    done

    read -p "Choisir un profil (numéro) : " choice
    profile_name="${profiles[$((choice-1))]}"
    public_key_file="$CONFIG_DIR/$profile_name/id_ed25519.pub"
    private_key_file="$CONFIG_DIR/$profile_name/id_ed25519"

    if [ ! -f "$public_key_file" ]; then
        echo -e "${RED}Erreur : Clé publique non trouvée pour le profil $profile_name.${NC}"
        return 1
    fi

    # Afficher la clé publique
    echo -e "\nVoici votre clé publique SSH :"
    echo -e "${GREEN}$(cat "$public_key_file")${NC}\n"

    # Instructions détaillées
    echo -e "${BLUE}Instructions pour ajouter la clé à GitHub :${NC}"
    echo "1. Copiez la clé ci-dessus :"
    if command -v xclip >/dev/null 2>&1; then
        echo "   - Utilisez 'xclip' pour copier :"
        echo "     xclip -sel clip < $public_key_file"
        echo "   - Ou exécutez cette commande maintenant ? [o/n]"
        read -p "   Choix : " copy_choice
        if [ "$copy_choice" = "o" ]; then
            xclip -sel clip < "$public_key_file"
            echo -e "${GREEN}Clé copiée dans le presse-papiers !${NC}"
        fi
    else
        echo "   - Copiez-collez la clé manuellement."
        echo "   - Voulez-vous installer xclip pour faciliter la copie ? [o/n]"
        read -p "   Choix : " xclip_choice
        if [ "$xclip_choice" = "o" ]; then
            pkg_manager=$(detect_package_manager)
            case $pkg_manager in
                apt) sudo apt-get install -y xclip ;;
                dnf) sudo dnf install -y xclip ;;
                pacman) sudo pacman -Sy --noconfirm xclip ;;
                *) echo -e "${RED}xclip non supporté pour ce gestionnaire de paquets.${NC}" ;;
            esac
        fi
    fi

    echo "2. Ouvrez votre navigateur et allez à :"
    echo "   https://github.com/settings/keys"
    echo "3. Cliquez sur 'New SSH key' ou 'Add SSH key'."
    echo "4. Entrez un titre (ex. 'Mon PC Linux')."
    echo "5. Collez la clé dans le champ 'Key' et cliquez sur 'Add SSH key'."
    echo "6. Testez la connexion :"
    echo "   ssh -T git@github.com -i $private_key_file"
    echo "   Voulez-vous tester maintenant ? [o/n]"
    read -p "   Choix : " test_choice
    if [ "$test_choice" = "o" ]; then
        # Capturer la sortie de ssh -T et vérifier si elle contient "successfully authenticated"
        ssh_output=$(ssh -T git@github.com -i "$private_key_file" 2>&1)
        if echo "$ssh_output" | grep -q "successfully authenticated"; then
            echo -e "${GREEN}Connexion à GitHub réussie !${NC}"
        else
            echo -e "${RED}Échec de la connexion. Vérifiez que la clé est bien ajoutée sur GitHub.${NC}"
            echo "Conseil : Assurez-vous de coller la clé sans espaces supplémentaires."
            echo "Détail de l'erreur : $ssh_output"
        fi
    fi
}

# Fonction pour afficher le menu principal
show_menu() {
    echo -e "${BLUE}=== Gestionnaire de Profils GitHub ===${NC}"
    echo "1. Ajouter un nouveau profil"
    echo "2. Changer de profil"
    echo "3. Voir le profil actuel"
    echo "4. Lister tous les profils"
    echo "5. Supprimer un profil"
    echo "6. Installer les dépendances"
    echo "7. Ajouter la clé SSH à GitHub"
    echo "q. Quitter"
    echo
    echo -n "Choix: "
}

# Fonction pour ajouter un nouveau profil
add_profile() {
    echo -e "${BLUE}=== Ajout d'un nouveau profil ===${NC}"
    read -p "Nom du profil: " profile_name
    read -p "Email GitHub: " git_email
    read -p "Nom d'utilisateur GitHub: " git_username
    
    # Vérifier si le profil existe déjà
    if [ -d "$CONFIG_DIR/$profile_name" ]; then
        echo -e "${RED}Erreur : Le profil $profile_name existe déjà.${NC}"
        return 1
    fi

    # Création du dossier pour le profil
    profile_dir="$CONFIG_DIR/$profile_name"
    mkdir -p "$profile_dir" || {
        echo -e "${RED}Erreur : Impossible de créer $profile_dir. Vérifiez les permissions.${NC}"
        return 1
    }
    
    # Sauvegarde des informations
    echo "$git_email" > "$profile_dir/email"
    echo "$git_username" > "$profile_dir/username"
    
    # Demander si l'utilisateur veut un mot de passe pour la clé SSH
    echo -n "Voulez-vous protéger la clé SSH avec un mot de passe ? (recommandé pour la sécurité) [o/n] "
    read passphrase_choice
    if [ "$passphrase_choice" = "o" ]; then
        # Générer une clé SSH avec mot de passe (l'utilisateur devra entrer le mot de passe)
        ssh-keygen -t ed25519 -C "$git_email" -f "$profile_dir/id_ed25519" || {
            echo -e "${RED}Erreur : Échec de la génération de la clé SSH.${NC}"
            return 1
        }
    else
        # Générer une clé SSH sans mot de passe
        ssh-keygen -t ed25519 -C "$git_email" -f "$profile_dir/id_ed25519" -N "" || {
            echo -e "${RED}Erreur : Échec de la génération de la clé SSH.${NC}"
            return 1
        }
    fi
    
    echo -e "${GREEN}Profil créé avec succès !${NC}"
    echo "Voici votre clé publique SSH à ajouter dans GitHub :"
    cat "$profile_dir/id_ed25519.pub"
    
    # Proposer d'ajouter la clé à GitHub
    echo -n "Voulez-vous ajouter la clé à GitHub maintenant ? [o/n] "
    read add_key_choice
    if [ "$add_key_choice" = "o" ]; then
        guide_ssh_key
    fi
}

# Fonction pour changer de profil
switch_profile() {
    echo -e "${BLUE}=== Changement de profil ===${NC}"
    profiles=($(find "$CONFIG_DIR" -maxdepth 1 -type d -not -path "$CONFIG_DIR" -exec basename {} \; 2>/dev/null))
    
    if [ ${#profiles[@]} -eq 0 ]; then
        echo -e "${RED}Aucun profil trouvé. Veuillez en créer un d'abord.${NC}"
        return
    fi
    
    echo "Profils disponibles :"
    for i in "${!profiles[@]}"; do
        echo "$((i+1)). ${profiles[$i]}"
    done
    
    read -p "Choisir un profil (numéro): " choice
    profile_name="${profiles[$((choice-1))]}"
    
    if [ -d "$CONFIG_DIR/$profile_name" ]; then
        # Configuration Git
        git config --global user.email "$(cat "$CONFIG_DIR/$profile_name/email")"
        git config --global user.name "$(cat "$CONFIG_DIR/$profile_name/username")"
        
        # Configuration SSH
        cp "$CONFIG_DIR/$profile_name/id_ed25519" "$HOME/.ssh/" || {
            echo -e "${RED}Erreur : Impossible de copier la clé SSH privée.${NC}"
            return 1
        }
        cp "$CONFIG_DIR/$profile_name/id_ed25519.pub" "$HOME/.ssh/" || {
            echo -e "${RED}Erreur : Impossible de copier la clé SSH publique.${NC}"
            return 1
        }
        chmod 600 "$HOME/.ssh/id_ed25519" || {
            echo -e "${RED}Erreur : Impossible de définir les permissions de la clé SSH.${NC}"
            return 1
        }
        
        # Enregistrement du profil actuel
        echo "$profile_name" > "$CURRENT_PROFILE_FILE"
        
        # Redémarrage de l'agent SSH
        eval "$(ssh-agent -s)" >/dev/null
        ssh-add "$HOME/.ssh/id_ed25519" || {
            echo -e "${RED}Erreur : Impossible d'ajouter la clé à l'agent SSH.${NC}"
            echo "Si la clé est protégée par un mot de passe, assurez-vous que l'agent SSH est actif et que le mot de passe est correct."
            return 1
        }
        
        echo -e "${GREEN}Profil changé avec succès pour $profile_name${NC}"
    else
        echo -e "${RED}Profil invalide${NC}"
    fi
}

# Fonction pour afficher le profil actuel
show_current_profile() {
    if [ -f "$CURRENT_PROFILE_FILE" ]; then
        current_profile=$(cat "$CURRENT_PROFILE_FILE")
        echo -e "${BLUE}Profil actuel: $current_profile${NC}"
        echo "Email: $(git config --global user.email)"
        echo "Nom: $(git config --global user.name)"
    else
        echo -e "${RED}Aucun profil actif${NC}"
    fi
}

# Fonction pour lister tous les profils
list_profiles() {
    echo -e "${BLUE}=== Profils disponibles ===${NC}"
    # Lister uniquement les dossiers dans $CONFIG_DIR
    profiles=($(find "$CONFIG_DIR" -maxdepth 1 -type d -not -path "$CONFIG_DIR" -exec basename {} \; 2>/dev/null))
    if [ ${#profiles[@]} -eq 0 ]; then
        echo "Aucun profil trouvé"
    else
        for profile in "${profiles[@]}"; do
            echo "$profile"
        done
    fi
}

# Fonction pour supprimer un profil
delete_profile() {
    echo -e "${BLUE}=== Suppression d'un profil ===${NC}"
    profiles=($(find "$CONFIG_DIR" -maxdepth 1 -type d -not -path "$CONFIG_DIR" -exec basename {} \; 2>/dev/null))
    
    if [ ${#profiles[@]} -eq 0 ]; then
        echo -e "${RED}Aucun profil à supprimer.${NC}"
        return
    fi
    
    echo "Profils disponibles :"
    for i in "${!profiles[@]}"; do
        echo "$((i+1)). ${profiles[$i]}"
    done
    
    read -p "Choisir un profil à supprimer (numéro): " choice
    profile_name="${profiles[$((choice-1))]}"
    
    if [ -d "$CONFIG_DIR/$profile_name" ]; then
        rm -rf "$CONFIG_DIR/$profile_name" || {
            echo -e "${RED}Erreur : Impossible de supprimer le profil $profile_name.${NC}"
            return 1
        }
        echo -e "${GREEN}Profil $profile_name supprimé avec succès${NC}"
        
        # Supprimer le profil actif si c'est celui supprimé
        if [ -f "$CURRENT_PROFILE_FILE" ] && [ "$(cat "$CURRENT_PROFILE_FILE")" = "$profile_name" ]; then
            rm -f "$CURRENT_PROFILE_FILE"
        fi
    else
        echo -e "${RED}Profil invalide${NC}"
    fi
}

# Vérification des dépendances au démarrage si activée
if [ "$CHECK_DEPS_ON_START" = true ]; then
    echo -e "${BLUE}Vérification des dépendances...${NC}"
    if ! command -v git >/dev/null 2>&1 || ! command -v ssh >/dev/null 2>&1; then
        echo "Certaines dépendances (Git ou SSH) sont manquantes. Installation..."
        install_dependencies || {
            echo -e "${RED}Échec de l'installation des dépendances. Le script peut ne pas fonctionner correctement.${NC}"
        }
    else
        echo -e "${GREEN}Toutes les dépendances sont satisfaites.${NC}"
    fi
fi

# Boucle principale
while true; do
    show_menu
    read choice
    case $choice in
        1) add_profile ;;
        2) switch_profile ;;
        3) show_current_profile ;;
        4) list_profiles ;;
        5) delete_profile ;;
        6) install_dependencies ;;
        7) guide_ssh_key ;;
        q) exit 0 ;;
        *) echo -e "${RED}Option invalide${NC}" ;;
    esac
    echo
done