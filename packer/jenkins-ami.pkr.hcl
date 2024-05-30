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
  //default     = "us-east-1"
}

variable "source_ami" {
  description = "The source Ubuntu 24.04 LTS AMI."
  type        = string
  default     = ""
  //default = "ami-04b70fa74e45c3917"
}

variable "ami-prefix" {
  type    = string
  default = ""
  //default = "Csye-7125-Packer-Image"
}

variable "subnet_id" {
  type        = string
  description = "Subnet of the default VPC"
  default     = ""
  // default     = "subnet-06bea9945ba667934"
}

variable "OS" {
  type        = string
  description = "Base operating system version"
  default     = ""
  //default     = "Ubuntu"
}

variable "ami_users" {
  type    = list(string)
  default = []
  // default = ["992382384015", "767398141113"]
}

variable "aws-access-key-id" {
  type = string
  //default = env("aws-access-key-id")
  default = "AKIA3FLD6LS4ZTECNNN5"
}

variable "aws-secret-access-key" {
  type = string
  //default = env("aws-secret-access-key")
  default = "Co1BFZXO4/33oJ7Ar+jAr5FF0ocpqsv8LOhh6Eul"

}

variable "instance_type" {
  description = "The instance type to use for the build."
  type        = string
  default     = ""
  // default     = "t2.micro"
}

variable "ssh_username" {
  description = "The SSH username to use."
  type        = string
  default     = ""
  // default     = "ubuntu"
}

variable "ami_name" {
  description = "The name of the created AMI."
  default     = "Jenkins-AMI"
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
      // "sudo bash -c 'cat > /etc/caddy/Caddyfile <<EOF\n{\n    acme_ca https://acme-staging-v02.api.letsencrypt.org/directory\n}\njenkins.centralhub.me {\n    reverse_proxy localhost:8080\n}\nEOF'",
      "sudo bash -c 'cat > /etc/caddy/Caddyfile <<EOF\njenkins.centralhub.me {\n    reverse_proxy 127.0.0.1:8080\n}\nEOF'",
      "sudo systemctl restart caddy"
    ]
  }


  post-processor "manifest" {
    output = "manifest.json"
  }
}
