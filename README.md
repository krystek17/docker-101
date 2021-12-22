# Docker-101

## Traefik

First install "mkcert" to generate self-signed certificate.

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
sudo pacman -Syu mkcert
```

Download the traefik directory and browse inside.

Create a directory for your certificates:
```
mkdir certs
```
Generate your certificates:
```
mkcert -install 

sudo mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem "localhost" "*.localhost"
```
Run:
```
docker-compose up -d 
```
Your dashboard is available at :

https://localhost/

And here are the other links:
  
https://wordpress.localhost/

https://drupal.localhost/

https://adminer.localhost/ 

https://traefik.localhost/

https://portainer.localhost/
 
Have fun ^^

## Caddy

Just:
```
docker-compose up -d
```
the links:

https://wordpress.localhost/

https://drupal.localhost/

https is not yet availble for adminer, portainer and homer

WIP
