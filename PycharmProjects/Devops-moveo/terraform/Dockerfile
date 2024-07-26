# Utilisez l'image officielle NGINX du dépôt Docker
FROM nginx:latest

# Supprimez la page par défaut de NGINX
RUN rm /usr/share/nginx/html/index.html

# Copiez votre page HTML personnalisée
COPY index.html /usr/share/nginx/html/

# Exposez le port 80 pour le serveur NGINX
EXPOSE 80
