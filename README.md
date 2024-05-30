## Assignment 1

### AWS Organization Setup:

Support for organizations was enabled in the AWS account.
A root dev and a prod were created.
AWS CLI was installed and configured on the development machine.
Root, D=dev and prod AWS CLI profiles were created, both set to use the us-east-1 region.

aws configure --profile env

### Jenkins Setup:

An IAM user named ghactions for GitHub Actions was created in the root AWS account.
A GitHub repository named ami-jenkins for Jenkins AMI was created and set up.
Jenkins AMI was built using Packer, including SSL configuration with Caddy or Nginx.
CI/CD for building Jenkins AMI with GitHub Actions was implemented.

### Domain Name & Route53:

Hosted zone was set up in Route53 for the domain name and the nameservers of the domain were registered in namecheap for the domain.
A subdomain jenkins.centralhub.me with a TTL of 60 seconds was created.

### GitHub Status Checks for AMIs:

GitHub status checks were enabled on the GitHub repository.
packer validate was configured to run on all pull requests.
A branch protection rule was added for the main branch.

### Setup GitHub Repository for Jenkins Infrastructure:

A GitHub repository named infra-jenkins for Jenkins infrastructure was created.

#### Enable GitHub Status Checks for Terraform Infrastructure:

A GitHub Actions workflow was created to run pr-check for validating Terraform code.

### Assign Elastic IP & DNS Record:

An Elastic IP address was allocated for the Jenkins instance in the ROOT AWS account.
A DNS A record jenkins.centralhub.me with the value of the allocated Elastic IP was added.

### Infrastructure as Code with Terraform:

Networking components such as VPC, subnets, route table, internet gateway, security groups, Network interface, etc., were set up.
EC2 instance with the Jenkins AMI was launched and terminated.
The allocated Elastic IP address was attached to the EC2 instance.
Caddy was configured to handle SSL certificate from Let's Encrypt and reverse proxy for Jenkins.
Proper logic was implemented to terminate the EC2 instance when tearing down the infrastructure.

## Packer Commands

### Initialization
Initialize a new Packer configuration:

packer init .

### Formatting
Format Packer configuration files for consistent style:

packer fmt jenkins-ami.pkr.hcl


### Validation
Validate syntax and configuration of Packer templates:

packer validate jenkins-ami.pkr.hcl


### Building
Build machine images based on Packer templates:

packer build jenkins-ami.pkr.hcl

