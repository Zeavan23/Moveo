provider "aws" {
  region = "us-east-1"
}

# Créer VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Créer le sous-réseau public
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# Créer une passerelle Internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Associer la passerelle Internet à la table de routage principale
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

# Créer un groupe de sécurité pour NGINX et SSH
resource "aws_security_group" "nginx_sg" {
  vpc_id = aws_vpc.main.id

  # Autoriser le trafic HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser le trafic SSH
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

# Créer une instance EC2 pour le serveur NGINX dans le sous-réseau public
resource "aws_instance" "nginx" {
  ami                    = "ami-014d544cfef21b42d" # AMI compatible x86_64
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  key_name               = "0708"
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  tags = {
    Name = "nginx-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              echo '<!DOCTYPE html><html><head><title>NGINX</title></head><body><h1>yo this is nginx</h1></body></html>' > /home/ec2-user/index.html
              sudo docker run -d -p 80:80 -v /home/ec2-user/index.html:/usr/share/nginx/html/index.html nginx
              EOF
}

# Sortie de l'adresse IP publique de l'instance NGINX
output "nginx_public_ip" {
  value = aws_instance.nginx.public_ip
}
