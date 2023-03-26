/*---------
  Global 
----------*/

variable "region" {
  description = "Region where the resources will be deployed"
  type        = string
  default     = "us-east-2"
}

variable "tags" {
  description = "Global tags applied to every resource by default"
  default = {
    Terraform = "true"
    Project   = "ghost"
  }
}

variable "env_prefix" {
  description = "Define the environemnt type e.g. Dev Test Prod"
  type        = string
  default     = "dev"
}

variable "my_ip" {
  description = "Your Public IP for SSH access to the APP server"
  type        = string
  default     = "0.0.0.0/0"
}

variable "image_name" {}


/*---------
  VPC 
----------*/

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "ghost_vpc"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "avail_zone" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "public_subnets" {
  description = "Public subnets where the ghost instances will be deployed"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "database_subnets" {
  description = "Private subvnets where the RDS instance will be deployed"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}


/*---------
  RDS MySQL DB using the latest Engine 
----------*/

variable "mysql_engine_version" {
  description = "Versions available: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html"
  type        = string
  default     = "8.0"
}

variable "mysql_instance_class" {
  description = "MySQL instance class"
  type        = string
  default     = "db.t2.micro"
}

variable "mysql_name" {
  description = "MySQL database name"
  type        = string
  default     = "ghostdb"
}

variable "mysql_username" {
  description = "MySQL admin username"
  type        = string
  default     = "admin"
}

variable "mysql_password" {
  description = "MySQL password"
  type        = string
  default     = "gKWUbloGjM8DzZyzcrAx"
}

variable "mysql_parameter_group_name" {
  description = "Mysql parameter group name"
  type        = string
  default     = "default.mysql8.0"
}


/*--------------------------------------------------------------------------------------------------
  EC2 / Auto Scaling Group (ASG)
  To make sure that the ASG always keep 1 healthy instance at all time (self healing), 
      define the asg_min_size and asg_max_size variables value to 1.
--------------------------------------------------------------------------------------------------*/

variable "ec2_instance_type" {
  description = "EC2 instance type used for Ghost"
  type        = string
  default     = "t2.micro"
}

variable "asg_max_size" {
  description = "ASG maximum instance count"
  type        = number
  default     = 1
}

variable "asg_min_size" {
  description = "ASG minumum instance count"
  type        = number
  default     = 1
}

variable "public_key_location" {
  description = "ASG maximum instance count"
  type        = string
  #  Don't forget to set this in terraform.tfvars if required"
}