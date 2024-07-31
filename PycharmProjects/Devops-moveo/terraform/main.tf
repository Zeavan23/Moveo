provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# Create private subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Associate Internet Gateway with Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create a Security Group for NGINX and SSH
resource "aws_security_group" "nginx_sg" {
  vpc_id = aws_vpc.main.id

  # Allow HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a Security Group for the Bastion Host
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.main.id

  # Allow SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP traffic for reverse proxy
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 Instance for the NGINX server in the private subnet
resource "aws_instance" "nginx" {
  ami                    = "ami-014d544cfef21b42d"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  key_name               = "0708"
  associate_public_ip_address = false

  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  tags = {
    Name = "nginx-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              echo '<!DOCTYPE html><html><head><title>NGINX</title></head><body><h1>yo this is nginx</h1></body></html>' > /home/ec2-user/index.html
              sudo docker run -d -p 80:80 -v /home/ec2-user/index.html:/usr/share/nginx/html/index.html nginx
              EOF
}

# Create a Bastion Host for SSH access in the public subnet
resource "aws_instance" "bastion" {
  ami                    = "ami-014d544cfef21b42d"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  key_name               = "0708"
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install nginx1.12 -y
              sudo service nginx start
              cat <<EOT > /etc/nginx/conf.d/reverse-proxy.conf
              server {
                  listen 80;
                  location / {
                      proxy_pass http://10.0.2.39:80;
                      proxy_set_header Host \$host;
                      proxy_set_header X-Real-IP \$remote_addr;
                      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto \$scheme;
                  }
              }
              EOT
              sudo systemctl restart nginx
              EOF
}

# Output the public IP of the Bastion host
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

# Output the private IP of the NGINX instance
output "nginx_private_ip" {
  value = aws_instance.nginx.private_ip
}
