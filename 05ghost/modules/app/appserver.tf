data "aws_ami" "latest-ubuntu-image" {
  
  most_recent = true
  owners = ["099720109477"]
  
  filter {
    name = "name"
    values = [var.image_name]
  }

  filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

#ssh-keygen
resource "aws_key_pair" "ssh-key" {
  key_name = "02example-key"
  public_key = file(var.public_key_location)
}

resource "aws_iam_instance_profile" "ghost_ec2_profile" {
  name = "GhostEC2-profile"
  role = aws_iam_role.ghost_ec2_role.name
}

resource "aws_iam_role" "ghost_ec2_role" {
  name = "GhostEC2-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.ghost_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_launch_configuration" "ghost_launch_configuration" {
  name_prefix          = "ghost-launch_config"
  image_id             = data.aws_ami.latest-ubuntu-image.image_id
  security_groups      = [aws_security_group.ghost_asg_sg.id]
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ghost_ec2_profile.name
  key_name             = aws_key_pair.ssh-key.key_name

  # path to the user data file
  user_data = templatefile("${path.module}/init.sh",
    {
      # This is pulled from the rds resource created in rds.tf
      "endpoint" = var.db_address,
      "database" = var.db_name,
      "username" = var.db_username,
      # !!! Remember to find a secure way to retrieve your password
      "password"  = var.db_password,
      "admin_url" = "${aws_lb.ghost_alb.dns_name}",
      "url"       = "${aws_lb.ghost_alb.dns_name}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}