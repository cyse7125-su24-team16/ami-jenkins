#!/bin/bash

# Install Caddy for Jenkins on Ubuntu 20.04 LTS.
sudo apt-get update

# Install Caddy
sudo apt-get install caddy -y

# Start Caddy
sudo systemctl enable caddy

# Caddy Status
sudo systemctl status caddy

#Creating a directory to save Caddy Certificates.
sudo mkdir -p /etc/caddy

#Saving Stagging SSL certificates.
sudo bash -c 'cat > /etc/caddy/Caddyfile <<EOF
{
    acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
}
jenkins.centralhub.me {
    reverse_proxy localhost:8080
}
EOF'


# Production Caddyfile Certificates.    
# sudo bash -c 'cat > /etc/caddy/Caddyfile <<EOF
# jenkins.centralhub.me {
#     reverse_proxy 127.0.0.1:8080
# }
# EOF'

# Restart Caddy.
sudo systemctl restart caddy
