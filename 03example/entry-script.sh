#!/bin/bash
sudo yum update -y && sudo yum install -y docker 
sudo systemctl start docker
sudo usermod -aG docker ec2-user
newgrp docker
docker run -p  80:80 nginx 