# Docker-101

Deploy a full stack with the folowing services:

- Wordpress
- Drupal
- Database
- Reverse Proxy

We are going to use the localhost as a domain. You can choose any reverse proxy you like. All options have the following in common:

  - .env 
```
DOMAIN=localhost
```
  -  init folder with a sql file
```
CREATE DATABASE IF NOT EXISTS `wordpress`;
CREATE DATABASE IF NOT EXISTS `drupal`;
GRANT ALL ON `wordpress`.* TO 'user'@'%';
GRANT ALL ON `drupal`.* TO 'user'@'%';
```
  - docker-compose.yml


## Table of contents

- [Certificates](#certificates)
- [Caddy](#caddy)
- [Nginx](#nginx)
- [Traefik](#traefik)
  - [Middlewares](#middlewares)

## Certificates
The certificates are needed only for traefik and nginx. Please follow the instruction corresponding to  your distro.

On ubuntu/debian:
```
sudo apt-get update

sudo apt install wget libnss3-tools

curl -s https://api.github.com/repos/FiloSottile/mkcert/releases/latest| grep browser_download_url  | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -

mv mkcert-v*-linux-amd64 mkcert

chmod a+x mkcert

sudo mv mkcert /usr/local/bin/
```
On archlinux:
```
sudo pacman -S nss

sudo pacman -Syu mkc
```
Create a directory for your certificates:
```
mkdir certs
```
Generate your certificates:
```
mkcert -install 

sudo mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem "localhost" "*.localhost"
```

## Caddy
Caddy has a very simple configuration, the Caddyfile will handle the https redirection.

Caddyfile:
```
drupal.{$DOMAIN} {
    reverse_proxy drupal:80
}

wordpress.{$DOMAIN} {
    reverse_proxy wordpress:80
}

```
docker-compose.yml :
```
version: "3.7"
services:

  caddy:
    image: caddy
    container_name: caddy
    hostname: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    environment:
      - DOMAIN
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./data:/data
      - ./config:/config

db:
     container_name: mysql
     image: mysql:8
     volumes:
      - db_data:/var/lib/mysql
      - ./init:/docker-entrypoint-initdb.d
     restart: always
     environment:
      MYSQL_ROOT_PASSWORD: test
      MYSQL_USER: user
      MYSQL_PASSWORD: test

  wordpress:
     depends_on:
      - db
     container_name: wordpress
     image: wordpress:5.8.2
     hostname: wordpress  
     environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: user
      WORDPRESS_DB_PASSWORD: test
      WORDPRESS_DB_NAME: wordpress
     restart: always
     volumes:
      - wordpress:/var/www/html

  drupal:
    depends_on:
      - db
    container_name: drupal
    hostname: drupal
    image: drupal:9.3
    restart: always
    environment:
      DRUPAL_DB_HOST: db:3306
      DRUPAL_DB-USER: user
      DRUPAL_DB_PASSWORD: test
      DRUPAL_DB_NAME: drupal
    volumes:
       - drupal_modules:/var/www/html/modules
       - drupal_profiles:/var/www/html/profiles
       - drupal_themes:/var/www/html/themes
       - drupal_sites:/var/www/html/sites
volumes:
    wordpress:
    drupal_modules:
    drupal_profiles:
    drupal_themes:
    drupal_sites:
    db_data: {}

```  
run:

```
docker-compose up -d
```
the links:

https://wordpress.localhost/

https://drupal.localhost/

**[`^        back to top        ^`](#)**

## Nginx
WIP

**[`^        back to top        ^`](#)**
## Traefik

First create a traefik.yml for you static configuration:
```
global:
  sendAnonymousUsage: false

api:
  dashboard: true
  insecure: false

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    watch: true
    exposedByDefault: false

  file:
    filename: /etc/traefik/config.yml
    watch: true

log:
  level: INFO
  format: common

entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https
          scheme: https
  https:
    address: ":443"
```
Then a tls.yml
```
http:
  routers:
    traefik:
      rule: "Host(`traefik.localhost`)"
      service: "api@internal"
      tls:
        domains:
          - main: "localhost"
            sans:
              - "*.localhost"
          - main: "domain.local"
            sans:
              - "*.domain.local"

tls:
  certificates:
    - certFile: "/etc/certs/local-cert.pem"
      keyFile: "/etc/certs/local-key.pem"
```
The **tls.yml** will handle the ssl certificates and the routing of traefik dashboard. While the **traefik.yml** will handle the redirection from port 80 to port 443, the activation of the dashboard and it will defines docker as a provider. This set up allow to easily add new services by just adding labels to docker-compose. Last but not least you don't to restart traefik when a new service is detected. 

and like with the other proxies you need a docker-compose.yml
```
version: '3'
services:
   db:
     container_name: mysql
     image: mysql:8
     volumes:
       - db_data:/var/lib/mysql
       - ./init:/docker-entrypoint-initdb.d
     restart: always
     environment:
       MYSQL_ROOT_PASSWORD: test
       MYSQL_USER: user
       MYSQL_PASSWORD: test

   wordpress:
     depends_on:
       - db
     container_name: wordpress
     image: wordpress:5.8.2
     environment:
       WORDPRESS_DB_HOST: db:3306
       WORDPRESS_DB_USER: user
       WORDPRESS_DB_PASSWORD: test
       WORDPRESS_DB_NAME: wordpress
     restart: always
     volumes:
       - wordpress:/var/www/html
     labels:
       - "traefik.http.routers.wordpress.rule=Host(`wordpress.$DOMAIN`)"
       - "traefik.enable=true"
       - "traefik.http.routers.wordpress.tls=true"
       - "traefik/http.routers.wordpress.tls.tls.domains[0].main=wordpress.$DOMAIN"
       - "traefik/http.routers.wordpress.tls.tls.domains[0].sans=wordpress-*.$DOMAIN"

   drupal:
     depends_on:
       - db
     container_name: drupal
     image: drupal:9.3
     restart: always
     environment:
       DRUPAL_DB_HOST: db:3306
       DRUPAL_DB-USER: user
       DRUPAL_DB_PASSWORD: test
       DRUPAL_DB_NAME: drupal
     volumes:
       - drupal_modules:/var/www/html/modules
       - drupal_profiles:/var/www/html/profiles
       - drupal_themes:/var/www/html/themes
       - drupal_sites:/var/www/html/sites
     labels:  
       - "traefik.http.routers.drupal.rule=Host(`drupal.$DOMAIN`)"
       - "traefik.enable=true"
       - "traefik.http.routers.drupal.tls=true"
       - "traefik/http.routers.drupal.tls.tls.domains[0].main=drupal.$DOMAIN"
       - "traefik/http.routers.drupal.tls.tls.domains[0].sans=drupal-*.$DOMAIN
       
   reverse-proxy:
     container_name: traefik
     image: traefik:v2.5
     # Enables the web UI and tells Traefik to listen to docker
     restart: always
     command: 
       - "--providers.docker"
     ports:
       - "80:80"
       - "443:443"
     volumes:
       # So that Traefik can listen to the Docker events
       - /var/run/docker.sock:/var/run/docker.sock
       # static conf
       - ./traefik.yml:/etc/traefik/traefik.yml:ro
       # dynamic conf
       - ./tls.yml:/etc/traefik/tls.yml:ro
       # self-signed certificate
       - ./certs:/etc/certs:ro
     labels:
       - "traefik.enable=true"
       - "traefik.http.routers.traefik=true"
       - "traefik.http.routers.api.rule=Host(`traefik.${DOMAIN}`)"
       - "traefik.http.routers.api.tls.certresolver=certificato"
       - "traefik.http.routers.api.tls.domains[0].main=*.${DOMAIN}"
       - "traefik.http.routers.api.service=api@internal"       

volumes:
    wordpress:
    drupal_modules:
    drupal_profiles:
    drupal_themes:
    drupal_sites:
    db_data: {}
 
```
Run:
```
docker-compose up -d 
```
the links:

https://wordpress.localhost/

https://drupal.localhost/

Https is also available for homer, adminer and portainer, please refer to traefik folder

**[`^        back to top        ^`](#)**
### Middlewares

**[`^        back to top        ^`](#)**
