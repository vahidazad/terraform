provider "aws" {}

variable "cidr_blocks" {
    description = "cidr blocks and names"
    type = list(object({
        cidr_block = string
        name = string
    }))
}

variable  "availability_zones" {
    description = "Availability Zones"
}

resource "aws_vpc" "dev-vpc" {
    cidr_block = var.cidr_blocks[0].cidr_block
    tags = {
      Name    : var.cidr_blocks[0].name
    }
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = var.availability_zones[0]
    tags = {
      "Name" = var.cidr_blocks[1].name
    }
}

output "dev-vpc-id" {
    value =  aws_vpc.dev-vpc.id
}

output "dev-subnet-id" {
    value =  aws_subnet.dev-subnet-1.id
}