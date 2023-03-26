resource "aws_db_instance" "ghost_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.mysql_subnet_group.name
  parameter_group_name   = var.db_parameter_group_name
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "main"
  subnet_ids = [var.db_subnet_ids[0], var.db_subnet_ids[1]]

  tags = merge(var.tags,
    {
      "Name" = "mysql-subnet-group"
  })
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql_sg"
  description = "mysql_sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "TCP"
    # Security group that will be used by the ASG, see asg.tf
    security_groups = [var.ghost_asg_sg.id]
  }

  egress {
    from_port = 3306
    to_port   = 3306
    protocol  = "TCP"
    # Security group that will be used by the ASG, see asg.tf
    security_groups = [var.ghost_asg_sg.id]
  }

  tags = merge(var.tags,
    {
      "Name" = "mysql-subnet-group"
  })
}