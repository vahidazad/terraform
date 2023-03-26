resource "aws_security_group" "ghost_asg_sg" {
  name        = "ghost-asg-sg"
  description = "Security group for the ghost instances"
  vpc_id      = var.ghost_vpc.vpc_id

  ingress {
    description = "Ingress rule for http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Security group that will be used by the ALB, see alb.tf
    security_groups = [aws_security_group.ghost_lb_sg.id]
  }

  ingress {
    description = "Ingress rule for ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ var.my_ip ] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags,
    {
      "Name" : "ghost-asg-sg"
  })
}

resource "aws_autoscaling_group" "ghost_asg" {
  name                 = "ghost-AutoScalingGroup"
  launch_configuration = aws_launch_configuration.ghost_launch_configuration.name
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = [var.ghost_vpc.public_subnets[0], var.ghost_vpc.public_subnets[1]]

  # Associate the ASG with the Application Load Balancer target group.
  target_group_arns = [aws_lb_target_group.ghost_lb_tg.arn]

  lifecycle {
    create_before_destroy = true
  }
}