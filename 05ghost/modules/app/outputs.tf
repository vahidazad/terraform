output "lb_dns_name" {
  value = aws_lb.ghost_alb.dns_name
}

output "ghostAutoScaling_sg" {
  value = aws_security_group.ghost_asg_sg
}