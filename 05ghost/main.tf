module "ghost_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name             = var.vpc_name
  cidr             = var.vpc_cidr_block
  azs              = var.avail_zone
  database_subnets = var.database_subnets
  public_subnets   = var.public_subnets

  tags = var.tags
}

module "ghost_db" {
  source = "./modules/db"
  db_engine_version         = var.mysql_engine_version
  db_instance_class         = var.mysql_instance_class
  db_name                   = var.mysql_name
  db_username               = var.mysql_username
  db_password               = var.mysql_password
  vpc_id                    = module.ghost_vpc.vpc_id
  db_subnet_ids             = module.ghost_vpc.database_subnets
  db_parameter_group_name   = var.mysql_parameter_group_name
  ghost_asg_sg              = module.app.ghostAutoScaling_sg
  tags                      = var.tags
}

module "app" {
  source = "./modules/app"
  instance_type             = var.ec2_instance_type
  image_name                = var.image_name
  avail_zone                = var.avail_zone
  public_key_location       = var.public_key_location
  db_address                = module.ghost_db.ghostDB.address
  db_name                   = var.mysql_name
  db_username               = var.mysql_username
  db_password               = var.mysql_password
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  ghost_vpc                 = module.ghost_vpc
  tags                      = var.tags
  my_ip                     = var.my_ip
}