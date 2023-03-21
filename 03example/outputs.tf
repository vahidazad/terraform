output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id  
}

output "myapp_ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}