#!/bin/bash

# Install Jenkins plugin manager tool
wget --quiet https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.0/jenkins-plugin-manager-2.13.0.jar

# Install plugins with jenkins-plugin-manager tool
sudo java -jar ./jenkins-plugin-manager-2.13.0.jar --war /usr/share/java/jenkins.war --plugin-download-directory /var/lib/jenkins/plugins --plugin-file /home/ubuntu/plugins.txt

#Creating a tar file of all the associated configuration files.
tar -czvf configs.tgz ./jcasc.yaml ./groovy_scripts/helloworld.groovy ./groovy_scripts/wizard.groovy ./groovy_scripts/login.groovy

#Change the ownership of the tar file to jenkins.
sudo chown ubuntu:ubuntu configs.tgz

# Move and extract Jenkins configuration files
cd /var/lib/jenkins/ || exit

#Create a directory to save the groovy scripts.
sudo mkdir /var/lib/jenkins/init.groovy.d

#Copying the Files in init directory to disable startup steps and login details.
sudo cp /home/ubuntu/groovy_scripts/wizard.groovy /var/lib/jenkins/init.groovy.d/
sudo cp /home/ubuntu/groovy_scripts/login.groovy /var/lib/jenkins/init.groovy.d/

# Updating Jenkins login details in login.groovy.
sudo sed -i 's/default/${var.jenkins_admin_user}/g' /var/lib/jenkins/init.groovy.d/login.groovy
sudo sed -i 's/default/${var.jenkins_admin_password}/g' /var/lib/jenkins/init.groovy.d/login.groovy
sudo systemctl restart jenkins

# Update users and group permissions to `jenkins` for all installed plugins
cd /var/lib/jenkins/plugins/ || exit
sudo chown jenkins:jenkins ./*

# Move and extract Jenkins configuration files
cd /home/ubuntu/ || exit
sudo mv configs.tgz /var/lib/jenkins/

# Update file ownership
cd /var/lib/jenkins/ || exit
sudo tar -xzvf configs.tgz
sudo chown jenkins:jenkins ./jcasc.yaml ./groovy_scripts/*.groovy

# Configure JAVA_OPTS to disable setup wizard
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
echo '[Service]' | sudo tee /etc/systemd/system/jenkins.service.d/override.conf
echo 'Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/jcasc.yml\"' | sudo tee -a /etc/systemd/system/jenkins.service.d/override.conf

# Increase Jenkins service timeout and check status and logs
echo 'Configuring Jenkins service timeout and checking status...'
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
echo '[Service]' | sudo tee /etc/systemd/system/jenkins.service.d/override.conf
echo 'TimeoutStartSec=600' | sudo tee -a /etc/systemd/system/jenkins.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart jenkins
sudo systemctl status jenkins