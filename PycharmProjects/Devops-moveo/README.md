DevOps Home Assignment
Overview
This project demonstrates how to deploy an NGINX instance on AWS using Terraform, Docker, and other infrastructure as code (IaC) tools. The NGINX instance will be publicly accessible and display the message "yo this is nginx" when accessed from a browser.

Architecture
The architecture consists of:

A Virtual Private Cloud (VPC) with public and private subnets.
An EC2 instance in the public subnet running a Dockerized NGINX server.
Security groups to control inbound and outbound traffic.
An internet gateway for internet access.
Prerequisites
AWS account with appropriate permissions to create resources.
Terraform installed on your local machine.
Docker installed on your local machine.
SSH key pair for accessing the EC2 instance.
Steps
1. AWS Infrastructure Setup with Terraform
Set up the AWS infrastructure using Terraform to create a VPC, subnets, an internet gateway, route tables, and security groups.

2. Docker Containerization
Use Docker to run an NGINX container that serves a simple HTML page displaying "yo this is nginx".

3. Deployment Steps
Initialize Terraform

Run terraform init to initialize the Terraform configuration.

Apply the Terraform Configuration

Run terraform apply -auto-approve to create the infrastructure and deploy the NGINX instance.

Retrieve the Public IP Address

After applying the configuration, Terraform will output the public IP address of the NGINX instance.

4. Accessing the NGINX Server
Open a web browser and navigate to the public IP address provided by Terraform. You should see the message "yo this is nginx".


5. One Click Installation
The terraform apply command handles the entire setup, from creating the infrastructure to deploying the Dockerized NGINX instance.

Verification Steps
Check Docker Containers

Ensure the NGINX container is running by executing sudo docker ps.

Check NGINX Logs

Review the logs to verify NGINX is serving the HTML page correctly.

GitHub Workflow (Bonus)
Create a GitHub Actions workflow to automate the deployment process. This workflow will initialize Terraform and apply the configuration whenever changes are pushed to specific branches.
