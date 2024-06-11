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

variable "github_username" {
  type        = string
  description = "The Jenkins admin user"
}

variable "github_password" {
  type        = string
  description = "The Jenkins admin password"
}

variable "docker_username" {
  type        = string
  description = "The Jenkins admin user"
}

variable "docker_password" {
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
    script = "./Scripts/Jenkins_Installation.sh"
  }

  provisioner "shell" {
    script = "./Scripts/Caddy_Setup.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "JENKINS_ADMIN_USER=${var.jenkins_admin_user}",
      "JENKINS_ADMIN_PASSWORD=${var.jenkins_admin_password}",
      "GITHUB_USERNAME=${var.github_username}",
      "GITHUB_PASSWORD=${var.github_password}",
      "DOCKER_USERNAME=${var.docker_username}",
      "DOCKER_PASSWORD=${var.docker_password}"

    ]
    script = "./Scripts/Confirguring_Jenkins.sh"
  }

  provisioner "shell" {
    script = "./Scripts/Docker_Installation.sh"
  }

  provisioner "shell" {
    script = "./Scripts/Packer_Installation.sh"
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}
