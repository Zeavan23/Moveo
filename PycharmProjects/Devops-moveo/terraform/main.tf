main.tf

provider "aws" {
  region = "us-east-1"  # שנה לאזור המתאים
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "allow_http" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow HTTP traffic"
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

  tags = {
    Name = "allow_http"
  }
}

resource "aws_instance" "nginx_backend" {
  ami           = "ami-0c55b159cbfafe1f0"  # שנה ל-AMI המתאים לאזור שלך
  instance_type = "t2.micro"

  # צור key pair לפני כן והוסף את שמו כאן
  key_name = "0708"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              mkdir /htmlfile
              echo '<!DOCTYPE html><html><head><title>NGINX</title></head><body><h1>yo this is nginx</h1></body></html>' > /htmlfile/index.html
              sudo docker run -d -p 80:80 -v /htmlfile/index.html:/usr/share/nginx/html/index.html nginx
              EOF

  vpc_security_group_ids = [aws_security_group.allow_http.id]
  subnet_id              = aws_subnet.main.id

  tags = {
    Name = "nginx-backend"
  }
}

resource "aws_instance" "nginx_reverse_proxy" {
  ami           = "ami-0c55b159cbfafe1f0"  # שנה ל-AMI המתאים לאזור שלך
  instance_type = "t2.micro"

  # צור key pair לפני כן והוסף את שמו כאן test
  key_name = "0708"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              cat <<EOT > /etc/nginx/nginx.conf
              events {
              }

              http {
                server {
                  listen 80;
                  location / {
                    proxy_pass http://${aws_instance.nginx_backend.private_ip};
                  }
                }
              }
              EOT
              systemctl restart nginx
              EOF

  vpc_security_group_ids = [aws_security_group.allow_http.id]
  subnet_id              = aws_subnet.main.id

  tags = {
    Name = "nginx-reverse-proxy"
  }
}

output "reverse_proxy_ip" {
  value = aws_instance.nginx_reverse_proxy.public_ip
}
