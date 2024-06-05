#!/bin/bash

# Install Java for Jenkins on Ubuntu 20.04 LTS
# Update package lists
sudo apt-get update

# Install fontconfig and OpenJDK 17
sudo apt install fontconfig openjdk-17-jre -y

# Check Java version:
echo "Java $(java -version)"

# Download Jenkins GPG key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add Jenkins repository to package sources.
echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package lists
sudo apt-get update

# Install Jenkins
sudo apt-get install -y jenkins

# Start Jenkins
sudo systemctl enable jenkins

# Start Jenkins
sudo systemctl start jenkins

# Check Jenkins version
echo "Jenkins $(jenkins --version)"
