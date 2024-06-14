#!/bin/bash
 
# Export Packer variables as environment variables
# Print the values of environment variables
echo "JENKINS_ADMIN_USER: ${JENKINS_ADMIN_USER}"
echo "JENKINS_ADMIN_PASSWORD: ${JENKINS_ADMIN_PASSWORD}"
echo "GITHUB_USERNAME: ${GITHUB_USERNAME}"
echo "GITHUB_PASSWORD: ${GITHUB_PASSWORD}"
echo "DOCKER_USERNAME: ${DOCKER_USERNAME}"
echo "DOCKER_PASSWORD: ${DOCKER_PASSWORD}"
 
 
# Install Jenkins plugin manager tool
wget --quiet https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.0/jenkins-plugin-manager-2.13.0.jar
 
# Install plugins with jenkins-plugin-manager tool
sudo java -jar ./jenkins-plugin-manager-2.13.0.jar --war /usr/share/java/jenkins.war --plugin-download-directory /var/lib/jenkins/plugins --plugin-file /home/ubuntu/plugins.txt
 
#Creating a tar file of all the associated configuration files.
tar -czvf configs.tgz ./jcasc.yaml ./groovy_scripts/helloworld.groovy ./groovy_scripts/wizard.groovy ./groovy_scripts/login.groovy ./groovy_scripts/static-site.groovy ./groovy_scripts/JenkinsAMI.groovy ./groovy_scripts/StaticSiteMultiPipeline.groovy ./groovy_scripts/Terraform.groovy ./groovy_scripts/Helm-Webapp-Cve-Processor.groovy ./groovy_scripts/k8s-manifests.groovy ./groovy_scripts/Webapp-Cve-Processor.groovy
 
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
# Use sed to replace placeholders in the login.groovy file
sudo sed -i "s/default/${JENKINS_ADMIN_USER}/g" /var/lib/jenkins/init.groovy.d/login.groovy
sudo sed -i "s/default/${JENKINS_ADMIN_PASSWORD}/g" /var/lib/jenkins/init.groovy.d/login.groovy
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

# Update file ownership for jcasc.yaml
sudo sed -i "s/git_username/${GITHUB_USERNAME}/g" /var/lib/jenkins/jcasc.yaml
sudo sed -i "s/ggit_password/${GITHUB_PASSWORD}/g" /var/lib/jenkins/jcasc.yaml
sudo sed -i "s/docker_username/${DOCKER_USERNAME}/g" /var/lib/jenkins/jcasc.yaml
sudo sed -i "s/docker_password/${DOCKER_PASSWORD}/g" /var/lib/jenkins/jcasc.yaml
sudo sed -i "s/jenkins_username/${JENKINS_ADMIN_USER}/g" /var/lib/jenkins/jcasc.yaml
sudo sed -i "s/jenkins_password/${JENKINS_ADMIN_PASSWORD}/g" /var/lib/jenkins/jcasc.yaml
sudo systemctl restart jenkins

# Configure JAVA_OPTS to disable setup wizard
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
{
  echo "[Service]"
  echo "Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/jcasc.yaml\""
} | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

   # Increase Jenkins service timeout and check status and logs
echo 'Configuring Jenkins service timeout and checking status...'
sudo systemctl daemon-reload
sudo systemctl stop jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

# # Set execute permissions for Groovy scripts
# sudo chmod +x /var/lib/jenkins/groovy_scripts/*.groovy
 
# # Check Jenkins service status
# sudo systemctl status jenkins
 
