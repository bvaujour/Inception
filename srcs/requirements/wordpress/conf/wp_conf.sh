#!/bin/bash

#---------------------------------------------------mariadb ping---------------------------------------------------#

ping_mariadb_container() {
    nc -zv mariadb 3306 > /dev/null
    return $?
}
start_time=$(date +%s)
end_time=$((start_time + 20))
while [ $(date +%s) -lt $end_time ]; do
    ping_mariadb_container
    if [ $? -eq 0 ]; then
        echo "[========MARIADB IS UP AND RUNNING========]"
        break
    else
        echo "[========WAITING FOR MARIADB TO START...========]"
        sleep 1
    fi
done

if [ $(date +%s) -ge $end_time ]; then
    echo "[========MARIADB IS NOT RESPONDING========]"
fi

#---------------------------------------------------wp installation---------------------------------------------------#

# Télécharge le fichier exécutable WP-CLI depuis le dépôt officiel
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Rend le fichier téléchargé exécutable
chmod +x wp-cli.phar

# Déplace l'exécutable WP-CLI vers un chemin global pour l'utiliser comme commande système
mv wp-cli.phar /usr/local/bin/wp

# Change de répertoire pour se placer dans le dossier WordPress
cd /var/www/wordpress

# Donne les permissions de lecture, écriture et exécution appropriées à tous les fichiers et dossiers
chmod -R 755 /var/www/wordpress/

# Change le propriétaire et le groupe des fichiers et dossiers en www-data (utilisé par le serveur web)
chown -R www-data:www-data /var/www/wordpress

# Déclare une fonction pour vérifier si WordPress est déjà installé
check_core_files() {
    # Vérifie si le cœur de WordPress est installé, en supprime la sortie
    wp core is-installed --allow-root > /dev/null
    # Retourne le code de sortie de la commande (0 si installé, 1 sinon)
    return $?
}

# Si WordPress n'est pas installé, exécute le processus d'installation
if ! check_core_files; then
    echo "[========WP INSTALLATION STARTED========]"
    # Supprime tous les fichiers existants dans le répertoire WordPress, sans supprimer le dossier lui-même
    find /var/www/wordpress/ -mindepth 1 -delete

    # Télécharge les fichiers principaux de WordPress
    wp core download --allow-root

    # Configure WordPress avec les paramètres de base de données
    wp core config --dbhost=mariadb:3306 --dbname="$MYSQL_DB" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --allow-root

    # Installe WordPress avec les informations du site et de l'administrateur
    wp core install --url="$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN_N" --admin_password="$WP_ADMIN_P" --admin_email="$WP_ADMIN_E" --allow-root

    # Crée un utilisateur WordPress supplémentaire avec les informations spécifiées
    wp user create "$WP_U_NAME" "$WP_U_EMAIL" --user_pass="$WP_U_PASS" --role="$WP_U_ROLE" --allow-root
else
    # Si WordPress est déjà installé, affiche un message et ignore l'installation
    echo "[========WordPress files already exist. Skipping installation========]"
fi
#---------------------------------------------------php config---------------------------------------------------#

# Modifie la configuration de PHP-FPM pour utiliser un port TCP au lieu d'un socket Unix
# -i : Modifie le fichier directement
# '36 s@/run/php/php7.4-fpm.sock@9000@' : 
#    - Va sur la ligne 36
#    - Remplace '/run/php/php7.4-fpm.sock' par '9000' (indiquant le port 9000 pour PHP-FPM)
sed -i '36 s@/run/php/php7.4-fpm.sock@9000@' /etc/php/7.4/fpm/pool.d/www.conf

# Crée le répertoire /run/php s'il n'existe pas
# Ce répertoire est souvent utilisé pour stocker les sockets ou autres fichiers temporaires nécessaires à PHP-FPM
mkdir -p /run/php

# Lance PHP-FPM en mode foreground (-F), pour que le processus reste actif et visible
# Cela est souvent utilisé dans des environnements comme Docker pour garder le conteneur en exécution
/usr/sbin/php-fpm7.4 -F