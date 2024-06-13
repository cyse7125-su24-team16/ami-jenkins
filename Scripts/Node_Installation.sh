#!/bin/bash

set -e

echo "Starting script execution..."

# Update the package list
echo "Updating package list..."
sudo apt update -y

# Install necessary packages
echo "Installing necessary packages..."
sudo apt install -y ca-certificates curl gnupg

# Create the directory for apt keyrings
echo "Creating directory for apt keyrings..."
sudo mkdir -p /etc/apt/keyrings

# Add NodeSource GPG key and setup repository
echo "Adding NodeSource GPG key..."
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

echo "Setting up NodeSource repository..."
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# Update the package list again to include Node.js packages
echo "Updating package list again..."
sudo apt update -y

# Install Node.js
echo "Installing Node.js..."
sudo apt install -y nodejs

# Verify Node.js and npm installation
echo "Verifying Node.js and npm installation..."
node --version
npm --version

# Install necessary global npm packages
echo "Installing global npm packages..."
sudo npm install -g semantic-release@latest

# Install local npm packages as dev dependencies
echo "Installing local npm packages..."
sudo npm install -g @semantic-release/git@latest
sudo npm install -g @semantic-release/exec@latest
sudo npm install -g conventional-changelog-conventionalcommits

# Install GitHub CLI
echo "Installing GitHub CLI..."
sudo npm install -g npm-cli-login
sudo apt install -y gh

# Confirm all installations
echo "Installation complete. Versions:"
node --version
npm --version
semantic-release --version
gh --version

echo "Script execution completed."
