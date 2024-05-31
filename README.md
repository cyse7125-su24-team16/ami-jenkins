## Jenkins AMI with HashiCorp Packer

### AWS Organization Setup

- Create organizations in the AWS account.
- Create root `dev` and `prod` organizational profiles.
- Install and configure AWS CLI on the development machine.
- For configuring the CLI, use the following [link](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).
- Create AWS CLI profiles for `dev` and `prod`, both set to use the `us-east-1` region.

    ```bash
    aws configure --profile dev
    aws configure --profile prod
    ```

### GitHub Status Checks

- Automated PR validation with `packer validate`.
- Branch protection for `main`.

## :package: [Packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli?in=packer/aws-get-started)

We will build a custom AMI (Amazon Machine Image) using Packer from HashiCorp.

### :arrow_heading_down: Installing Packer

#### Installing Packer on Windows

1. **Install Chocolatey package manager**
    - Open PowerShell as Administrator.
    - Run the following command to install Chocolatey:

    ```shell
    @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    ```

2. **Install Packer**
    - Once Chocolatey is installed, you can install Packer by running the following command:

    ```shell
    choco install packer
    ```

3. **Update Packer**
    - Update Packer:

    ```shell
    choco upgrade packer
    ```

4. **Verify Packer installation**
    - Verify Packer is installed properly:

    ```shell
    packer
    ```

### :wrench: Building Custom AMI using Packer

Packer uses HashiCorp Configuration Language (HCL) to create a build template. We'll use the [Packer docs](https://www.packer.io/docs/templates/hcl_templates) to create the build template file.

> **NOTE:** The file should end with the `.pkr.hcl` extension to be parsed using the HCL2 format.

#### Create the `.pkr.hcl` template

The custom AMI should have the following features:

> **NOTE:** The builder to be used is `amazon-ebs`.

- **OS:** `Ubuntu 24.04 LTS`
- **Build:** Built on the default VPC
- **Device Name:** `/dev/sda1/`
- **Volume Size:** `8GiB`
- **Volume Type:** `gp2`
- Have valid `provisioners`.
- Pre-installed dependencies using a shell script.
- Jenkins pre-installed on the AMI.

#### Shell Provisioners

This will automate the process of updating the OS packages and installing software on the AMI and will have our application in a running state whenever the custom AMI is used to launch an EC2 instance. It should also copy artifacts to the AMI in order to get the application running. It is important to bootstrap our application here, instead of manually SSH-ing into the AMI instance.

Install application prerequisites, middlewares, and runtime dependencies here. Update the permission and file ownership on the copied application artifacts.

> **NOTE:** The file provisioners must copy the application artifacts and configuration to the right location.

#### Custom AMI creation

To create the custom AMI from the `.pkr.hcl` template created earlier, use the commands given below:

1. **Initialize Packer plugins** (if you're using Packer plugins):

    ```shell
    # Installs all packer plugins mentioned in the config template
    packer init .
    ```

2. **Format the template**:

    ```shell
    packer fmt .
    ```

3. **Validate the template**:

    ```shell
    # To validate syntax only
    packer validate -syntax-only .
    # To validate the template as a whole
    packer validate -evaluate-datasources .
    ```

4. **Build the custom AMI using Packer**:

    ```shell
    packer build <filename>.pkr.hcl
    ```

#### Packer HCL Variables

To prevent pushing sensitive details to your version control, we can have variables in the `<filename>.pkr.hcl` file and then declare the actual values for these variables in another HCL file with the extension `.pkrvars.hcl`.

1. **Validate your build configuration**:

    ```shell
    packer validate -evaluate-datasources --var-file=<variables-file>.pkrvars.hcl <build-config>.pkr.hcl
    ```

2. **Build with variables**:

    ```shell
    packer build --var-file=<variables-file>.pkrvars.hcl <build-config>.pkr.hcl
    ```

> **NOTE:** It is considered best practice to build a custom AMI with variables using HCP Packer!

## ⤵️ Install Required Software

In order for Jenkins to run, it requires `Java`.

### ☕️ Java Installation

```bash
# Installing Java
sudo apt-get update
sudo apt install fontconfig openjdk-17-jre -y
# Validate installation
java -version


# 💁‍♂️ Jenkins Installation

# Installing Jenkins

    ## Installing Jenkins on Debian-based Linux

    To install Jenkins on Debian-based Linux distributions, follow these steps:

    ### Step 1: Download Jenkins GPG key
    - Run the following command to download the Jenkins GPG key:
    ```shell
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

    ### Step 2: Add Jenkins repository to package sources
    - Add the Jenkins repository to the package sources by running
    ```shell
        echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

    ### Step 3: Update package lists.
    - Run the following command to update the package lists.
    ```shell
        sudo apt-get update

    ### Step 4: Install Jenkins.
    - Install Jenkins by running the following command:
    ```shell
        sudo apt-get update

    ### Step 5: Enable Jenkins Service.
    - Enable the Jenkins service to start automatically on system boot by running:
    ```shell
        sudo systemctl enable jenkins

    ## 🔒 Configure Caddy Service

    ```bash
    # Install and enable caddy:
    sudo apt update # required to refresh apt with the newly installed keys.
    sudo apt-get install caddy -y
    sudo systemctl enable caddy
    sudo systemctl status caddy

     ## Configuring Caddy for Jenkins Reverse Proxy

    To configure Caddy as a reverse proxy for Jenkins on your server, follow these steps:

    ### Step 1: Create Caddy Configuration Directory
    - Run the following command to create the Caddy configuration directory:
    ```shell
    sudo mkdir -p /etc/caddy

    This command creates a directory /etc/caddy where Caddy configuration files will be stored.

    ### Step 2: Create Caddy Configuration File
    Use the following command to create the Caddy configuration file /etc/caddy/Caddyfile:
    ```shell
        sudo bash -c 'cat > /etc/caddy/Caddyfile <<EOF\n{\n    acme_ca https://acme-staging-v02.api.letsencrypt.org/directory\n}\njenkins.centralhub.me {\n    reverse_proxy localhost:8080\n}\nEOF'

    This command creates a Caddyfile with the following configuration:
    Uses the Let's Encrypt staging environment for certificate issuance (acme_ca https://acme-staging-v02.api.letsencrypt.org/directory).
    Configures a reverse proxy for the domain jenkins.centralhub.me, forwarding requests to Jenkins running on localhost:8080.




