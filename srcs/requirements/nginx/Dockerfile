FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y nginx openssl

# SSL
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=mablatie.42.fr/UID=mablatie"
#-x509 = certificat auto signe au lieu d'une request / -nodes = creation auto sans mdp / 
# -out -keyout = la ou on stock les fichiers correspond au certif et la cle / -subj = permet de rajouter les informations necessaires demander lors de l'exec de openssl pour le certificat TSL

# Copy de la config nginx dans l'image
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Creation du dossier wordpress
RUN mkdir -p /var/www/wordpress

# Change le proprietaire du dossier wordpress a www-data (utilisateur/groupe par defaut)
RUN chown -R www-data:www-data /var/www/wordpress

#-g daemon off = permet au container d'etre en foreground, si il etait en background le container exiterai apres execution
CMD ["nginx", "-g", "daemon off;"]
