resource "aws_security_group" "myapp_sg" {
  name = "myapp_sg"
  vpc_id = var.vpc_id
  
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
    from_port = 80
    to_port = 80
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
    values = [var.image_name]
  }
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry-script.sh")

  tags = {
    "Name" = "web - ${terraform.workspace}"
  }
}

#ssh-keygen
resource "aws_key_pair" "ssh-key" {
  key_name = "02example-key"
  public_key = file(var.public_key_location)
}
