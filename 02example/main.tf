provider "aws" {
    region = "eu-west-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable  "avail_zone" {}
variable "env" {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name    : "${var.avail_zone}-myapp-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
      "Name" = "${var.avail_zone}-myapp-subnet-1"
    }
}