packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  description = "The AWS region to deploy to."
  default     = "us-east-1"
}

variable "source_ami" {
  description = "The source Ubuntu 24.04 LTS AMI."
  default     = "ami-04b70fa74e45c3917"
}

variable "instance_type" {
  description = "The instance type to use for the build."
  default     = "t2.micro"
}

variable "ssh_username" {
  description = "The SSH username to use."
  default     = "ubuntu"
}

variable "ami_name" {
  description = "The name of the created AMI."
  default     = "jenkins-ami"
}

locals {
  timestamp = regex_replace(formatdate("YYYY-MM-DD-hh-mm-ss", timestamp()), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  region          = var.aws_region
  source_ami      = var.source_ami
  instance_type   = var.instance_type
  ssh_username    = var.ssh_username
  ami_name        = "${var.ami_name}--${local.timestamp}"
  ami_description = "Jenkins AMI built with Packer"


  access_key = "AKIA3FLD4S4RQROHAOFE"
  secret_key = "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"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

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
}
