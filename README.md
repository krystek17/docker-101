# docker-101

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

Enter your directory and use the following command:
```
<p>mkdir certs init<p>

mkcert -install
  
mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem "docker.localhost" "*.docker.localhost" "domain.local" "*.domain.local"

touch ./init/01.sql

touch docker-compose.yml

docker-compose up -d 
```
the links:
  
https://wordpress.docker.localhost

https://drupal.docker.localhost

https://adminer.docker.localhost/ 

To install a dashboard import the homer's directory into your docker folder
```
 docker-compose up -d 
```  
 And now you have a dashboard at https://docker.localhost 
  
have fun ^^
