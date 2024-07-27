DevOps Home Assignment - README
Overview
This project demonstrates how to deploy an NGINX instance on AWS using Terraform, Docker, and other infrastructure as code (IaC) tools. The NGINX instance will be publicly accessible and display the message "yo this is nginx" when accessed from a browser.

Architecture
The architecture consists of:

A Virtual Private Cloud (VPC) with public and private subnets.
An EC2 instance in the private subnet running a Dockerized NGINX server.
A Bastion host in the public subnet serving as a reverse proxy.
Security groups to control inbound and outbound traffic.
An internet gateway for internet access.
Prerequisites
AWS account with appropriate permissions to create resources.
Terraform installed on your local machine.
Docker installed on your local machine.
SSH key pair for accessing the EC2 instances.
Steps
1. AWS Infrastructure Setup with Terraform
Set up the AWS infrastructure using Terraform to create a VPC, subnets, an internet gateway, route tables, and security groups. The Terraform configuration file main.tf includes all necessary resource definitions.

2. Docker Containerization
Use Docker to run an NGINX container that serves a simple HTML page displaying "yo this is nginx".

3. Deployment Steps
Initialize Terraform

bash
Copy code
terraform init
Apply the Terraform Configuration

bash
Copy code
terraform apply -auto-approve
This command will create the infrastructure and deploy the NGINX instance.

Retrieve the Public IP Address

After applying the configuration, Terraform will output the public IP address of the Bastion host.

4. Reverse Proxy Setup
The Bastion host is configured to act as a reverse proxy. This setup ensures that the NGINX instance, residing in a private subnet, is accessible via the Bastion host.

Nginx Configuration on Bastion Host

The Bastion host runs NGINX with the following configuration to forward traffic to the NGINX instance:

nginx
Copy code
server {
    listen 80;
    location / {
        proxy_pass http://10.0.2.39:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
5. Accessing the NGINX Server
Open a web browser and navigate to the public IP address provided by Terraform. You should see the message "yo this is nginx".

6. One Click Installation
The terraform apply command handles the entire setup, from creating the infrastructure to deploying the Dockerized NGINX instance.

Verification Steps
Check Docker Containers

Ensure the NGINX container is running by executing:

bash
Copy code
sudo docker ps
Check NGINX Logs

Review the logs to verify NGINX is serving the HTML page correctly.

GitHub Workflow (Bonus)
Create a GitHub Actions workflow to automate the deployment process. This workflow will initialize Terraform and apply the configuration whenever changes are pushed to specific branches.
