# docker-101

first install "mkcert" to generate self-signed certificate.
mkcert -install


Enter your directory and use the following command:
<p>mkdir certs<p>
mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem "docker.localhost" "*.docker.localhost" "domain.local" "*.domain.local"

mkdir init
touch ./init/01.sql
touch docker-compose.yml

docker-compose up -d 


have fun ^^
