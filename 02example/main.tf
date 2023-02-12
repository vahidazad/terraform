provider "aws" {
    region = "eu-west-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable  "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location" {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name    : "${var.env_prefix}-myapp-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
      "Name" = "${var.env_prefix}-myapp-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
      Name : "${var.env_prefix}-myapp-igw"
    }
}

resource "aws_route_table" "myapp_rtbl" {
  vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-myapp-rtbl"
  }
}

resource "aws_route_table_association" "rtass" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp_rtbl.id
  
}

resource "aws_security_group" "myapp_sg" {
  name = "myapp_sg"
  vpc_id = aws_vpc.myapp-vpc.id
  
  ingress {
    description = "SSH rule from my PC"
    cidr_blocks = [ var.my_ip ] 
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  ingress {
    description = "HTTP access"
    cidr_blocks = ["0.0.0.0/0" ] 
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
  }

  egress {
    description = "Server outgoing access"
    cidr_blocks = ["0.0.0.0/0" ] 
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  
  tags = {
    "Name" = "${var.env_prefix}-myapp-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = <<EOF
                  #!/bin/bash
                  sudo yum update -y && sudo yum install -y docker 
                  sudo systemctl start docker
                  sudo usermod -aG docker ec2-user
                  newgrp docker
                  docker run -p  8080:80 nginx 
              EOF
  
  tags = {
    "Name" = "${var.env_prefix}-myapp-server"
  }
}

#ssh-keygen
resource "aws_key_pair" "ssh-key" {
  key_name = "02example-key"
  public_key = file(var.public_key_location)
}
output "aws_instance-public-ip" {
  value = aws_instance.myapp-server.public_ip
}