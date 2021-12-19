# Docker-101

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

Download the becode directory and browse inside.

Create a directory for your certificates:
```
mkdir certs
```
Generate your certifactes:
```
mkcert -install 

sudo mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem "localhost" "*.localhost"
```
Run docker:
```
docker-compose up -d 
```
Access your links:
  
https://wordpress.localhost/

https://drupal.localhost/

https://adminer.localhost/ 

https://traefik.localhost/

To install a dashboard import the homer's directory into your docker folder
```
 docker-compose up -d 
```  
 And now you have a dashboard at https://localhost/
 
 If you want to use portainer its the same, just download the portainer directory and run docker-compose
 
 https://portainer.localhost
 
Have fun ^^
