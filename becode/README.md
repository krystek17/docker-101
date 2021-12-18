# docker-101

first install "mkcert" to generate self-signed certificate.
mkcert -install


Enter your directory and use the following command:
<p>mkdir certs init<p>
mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem "docker.localhost" "*.docker.localhost" "domain.local" "*.domain.local"

touch ./init/01.sql

touch docker-compose.yml

docker-compose up -d 

the links:
  
https://wordpress.docker.localhost

https://drupal.docker.localhost

https://adminer.docker.localhost/ 
  
have fun ^^
