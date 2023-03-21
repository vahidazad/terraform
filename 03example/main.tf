resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name    : "${var.env_prefix}-myapp-vpc"
    }
}

module "myapp-subnet" {
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp-vpc.id
}

module "myapp-webserver" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.myapp-vpc.id
  my_ip  = var.my_ip
  env_prefix = var.env_prefix
  instance_type = var.instance_type
  avail_zone = var.avail_zone
  public_key_location = var.public_key_location
  image_name = var.image_name
  subnet_id = module.myapp-subnet.subnet.id
}
