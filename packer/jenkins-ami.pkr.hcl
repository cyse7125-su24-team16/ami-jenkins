packer {
  required_plugins {
    git = {
      version = ">= v0.4.3"
      source  = "github.com/ethanmdavidson/git"
    }

    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

          variable "aws_region" {
  description = "The AWS region to deploy to."
  type        = string
  default     = ""
}

variable "source_ami" {
  description = "The source Ubuntu 24.04 LTS AMI."
  type        = string
  default     = ""
}

variable "ami-prefix" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type        = string
  description = "Subnet of the default VPC"
  default     = ""
}

variable "OS" {
  type        = string
  description = "Base operating system version"
  default     = ""
}

variable "ami_users" {
  type    = list(string)
  default = []
}

variable "aws-access-key-id" {
  type    = string
  default = env("aws-access-key-id")
}

variable "aws-secret-access-key" {
  type    = string
  default = env("aws-secret-access-key")

}

variable "instance_type" {
  description = "The instance type to use for the build."
  type        = string
  default     = ""
}

variable "ssh_username" {
  description = "The SSH username to use."
  type        = string
  default     = ""
}

variable "ami_name" {
  description = "The name of the created AMI."
  default     = "Jenkins-AMI"
}

variable "jenkins_admin_user" {
  type        = string
  description = "The Jenkins admin user"
}

variable "jenkins_admin_password" {
  type        = string
  description = "The Jenkins admin password"
}

locals {
  timestamp = regex_replace(formatdate("YYYY-MM-DD-hh-mm-ss", timestamp()), "[- TZ:]", "")
}


source "amazon-ebs" "ubuntu" {
  region          = "${var.aws_region}"
  ami_name        = "${var.ami_name}--${local.timestamp}"
  ami_description = "Building Jenkins AMI built with Packer"
  ami_users       = "${var.ami_users}"
  instance_type   = "${var.instance_type}"
  source_ami      = "${var.source_ami}"
  ssh_username    = "${var.ssh_username}"
  subnet_id       = "${var.subnet_id}"
  ami_regions     = ["${var.aws_region}", ]
  access_key      = "${var.aws-access-key-id}"
  secret_key      = "${var.aws-secret-access-key}"

  tags = {
    Name = "csye7125Jenkins_${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  }

  aws_polling {
    delay_seconds = 120
    max_attempts  = 50
  }

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "./packer"
    destination = "/home/ubuntu/packer"
  }

  provisioner "file" {
    source      = "./jenkins/plugins.txt"
    destination = "/home/ubuntu/plugins.txt"
  }

  provisioner "file" {
    source      = "jenkins/jcasc.yaml"
    destination = "/home/ubuntu/jcasc.yaml"
  }

  provisioner "file" {
    source      = "./groovy_scripts"
    destination = "/home/ubuntu/groovy_scripts"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt install fontconfig openjdk-17-jre -y",
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y jenkins",
      "sudo systemctl enable jenkins",
    ]
  }
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install caddy -y",
      "sudo systemctl enable caddy",
      "sudo systemctl status caddy",
      "sudo mkdir -p /etc/caddy",
      //"sudo bash -c 'cat > /etc/caddy/Caddyfile <<EOF\n{\n    acme_ca https://acme-staging-v02.api.letsencrypt.org/directory\n}\njenkins.centralhub.me {\n    reverse_proxy localhost:8080\n}\nEOF'",
      "sudo bash -c 'cat > /etc/caddy/Caddyfile <<EOF\njenkins.vaishnavimantri.me {\n    reverse_proxy 127.0.0.1:8080\n}\nEOF'",
      "sudo systemctl restart caddy"
    ]
  }

  provisioner "shell" {
    inline = [
      # Install Jenkins plugin manager tool
      "wget --quiet https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.0/jenkins-plugin-manager-2.13.0.jar",

      # Install plugins with jenkins-plugin-manager tool
      "sudo java -jar ./jenkins-plugin-manager-2.13.0.jar --war /usr/share/java/jenkins.war --plugin-download-directory /var/lib/jenkins/plugins --plugin-file /home/ubuntu/plugins.txt",

      "tar -czvf configs.tgz ./jcasc.yaml ./groovy_scripts/helloworld.groovy ./groovy_scripts/wizard.groovy ./groovy_scripts/login.groovy",
      "sudo chown ubuntu:ubuntu configs.tgz",

      "cd /var/lib/jenkins/",
      "sudo mkdir /var/lib/jenkins/init.groovy.d",
      "sudo cp /home/ubuntu/groovy_scripts/wizard.groovy /var/lib/jenkins/init.groovy.d/",
      "sudo cp /home/ubuntu/groovy_scripts/login.groovy /var/lib/jenkins/init.groovy.d/",

      "sudo sed -i 's/default/${var.jenkins_admin_user}/g' /var/lib/jenkins/init.groovy.d/login.groovy",
      "sudo sed -i 's/default/${var.jenkins_admin_password}/g' /var/lib/jenkins/init.groovy.d/login.groovy",
      "sudo systemctl restart jenkins",

      # Update users and group permissions to `jenkins` for all installed plugins:
      "cd /var/lib/jenkins/plugins/ || exit",
      "sudo chown jenkins:jenkins ./*",

      # Move and extract Jenkins configuration files
      "cd /home/ubuntu/ || exit",
      "sudo mv configs.tgz /var/lib/jenkins/",

      # Update file ownership
      "cd /var/lib/jenkins/ || exit",
      "sudo tar -xzvf configs.tgz",
      "sudo chown jenkins:jenkins ./jcasc.yaml ./groovy_scripts/*.groovy",

      # Configure JAVA_OPTS to disable setup wizard
      "sudo mkdir -p /etc/systemd/system/jenkins.service.d/",
      "echo '[Service]' | sudo tee /etc/systemd/system/jenkins.service.d/override.conf",
      "echo 'Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/var/lib/jenkins/jcasc.yml\"' | sudo tee -a /etc/systemd/system/jenkins.service.d/override.conf",

      # Increase Jenkins service timeout and check status and logs
      "echo 'Configuring Jenkins service timeout and checking status...'",
      "sudo mkdir -p /etc/systemd/system/jenkins.service.d/",
      "echo '[Service]' | sudo tee /etc/systemd/system/jenkins.service.d/override.conf",
      "echo 'TimeoutStartSec=600' | sudo tee -a /etc/systemd/system/jenkins.service.d/override.conf",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart jenkins",
      "sudo systemctl status jenkins"
    ]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}
