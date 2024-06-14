#!/bin/bash

# Update package list
sudo apt-get update

# Install Caddy
sudo apt-get install caddy -y

# Enable and start Caddy service
sudo systemctl enable caddy
sudo systemctl start caddy

# Check Caddy status
sudo systemctl status caddy

# Create a directory to save Caddy certificates if it doesn't exist
sudo mkdir -p /etc/caddy

# Create and save the staging SSL certificates in the Caddyfile
sudo bash -c 'cat > /etc/caddy/Caddyfile <<EOF
{
    acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
}
jenkins.centralhub.me {
    reverse_proxy localhost:8080
}
EOF'

# If you want to use production SSL certificates, uncomment and use the following block
# Create and save the production SSL certificates in the Caddyfile
# sudo bash -c 'cat > /etc/caddy/Caddyfile <<EOF
# jenkins.centralhub.me {
#     reverse_proxy 127.0.0.1:8080
# }
# EOF'

# Restart Caddy to apply the new configuration
sudo systemctl restart caddy

# Output the status of the Caddy service
sudo systemctl status caddy
