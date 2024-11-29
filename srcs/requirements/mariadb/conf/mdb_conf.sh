#!/bin/sh

# Démarre le service MariaDB
service mariadb start

# Attend 5 secondes pour s'assurer que le service MariaDB est complètement lancé avant d'exécuter des commandes
sleep 5

#---------------------------------------------------Configuration de MariaDB---------------------------------------------------#

# Crée une base de données si elle n'existe pas déjà
# \`${MYSQL_DB}\` : Utilise une variable d'environnement pour définir le nom de la base de données
mariadb -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;"

# Crée un utilisateur avec un mot de passe défini dans les variables d'environnement, si cet utilisateur n'existe pas déjà
# \`${MYSQL_USER}\`@'%' : '@'%' permet à l'utilisateur de se connecter depuis n'importe quelle adresse IP
mariadb -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

# Accorde tous les privilèges sur la base de données spécifiée à l'utilisateur nouvellement créé
mariadb -e "GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO \`${MYSQL_USER}\`@'%';"

# Recharge les privilèges pour appliquer les changements immédiatement
mariadb -e "FLUSH PRIVILEGES;"

# Modifie le mot de passe du compte root pour sécuriser l'accès
# 'root'@'localhost' : Cette commande cible spécifiquement le compte root local
mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

#---------------------------------------------------Redémarrage de MariaDB---------------------------------------------------#

# Arrête proprement le serveur MariaDB
mysqladmin -u root -p$MYSQL_ROOT_PASSWORD shutdown

# Relance MariaDB en mode sécurisé, avec des paramètres spécifiques
# --port=3306 : Configure le port d'écoute pour MariaDB (port standard : 3306)
# --bind-address=0.0.0.0 : Autorise les connexions depuis n'importe quelle adresse IP
# --datadir='/var/lib/mysql' : Définit le répertoire contenant les données de MariaDB
mysqld_safe --port=3306 --bind-address=0.0.0.0 --datadir='/var/lib/mysql'
