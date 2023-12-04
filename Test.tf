terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

#  resource "aws_instance" "test-instance" {
#    ami           = "ami-0416c18e75bd69567"
#    instance_type = "t3.micro"
#    key_name = "private_key"

#    tags = {
#      Name = "machine from terraform1"
#    }  
#  } 

#  # creating EIP for instance

#  resource "aws_eip" "lb" {
#   instance = aws_instance.test-instance.id
  
#  } 

# creating infrastructure

resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "main"
  }
}
 # subnets
  
  
 resource "aws_subnet" "ap-south-1a" {
   vpc_id     = aws_vpc.demo_vpc.id
   cidr_block = "10.10.0.0/24"
   availability_zone = "ap-south-1a"
   map_public_ip_on_launch = "true"

   tags = {
    Name = "ap-south-1a"
   }
 }

 resource "aws_subnet" "ap-south-1b" {
   vpc_id     = aws_vpc.demo_vpc.id
   cidr_block = "10.10.1.0/24"
   availability_zone = "ap-south-1b"
   map_public_ip_on_launch = "true"

   tags = {
    Name = "ap-south-1b"
   }
 }

 resource "aws_subnet" "ap-south-1c" {
   vpc_id     = aws_vpc.demo_vpc.id
   cidr_block = "10.10.2.0/24"
   availability_zone = "ap-south-1c"

   tags = {
    Name = "ap-south-1c"
   }
 }

 

# create key pair

resource "aws_key_pair" "mumbai-key" {
  key_name   = "mumbai-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDlOgWusu2Nx1vhWUKcrWHVVeV1BXv17Hu3iGtvZjmqe3Bha13TlMwPLiBLPv4iRxKHrV3fKB9ahVWwz4Vil3bWc9HxL8bEZgcxpIK864Z8fSQiSQTeHyl1Cijo9tfOwg5H8t4ZFipJGfFn/baXZBfGL5fPYBgPnXsI/OZIRkywX6Z0alif8Im8+zI8eC1RFu7J3+Zv8ufDKKNY82TPRKKbihhsjzA8LHvoplYIuXYUcwiMTausriHd2JSiDhQ1zvMxITuEuuomJ1NAE0NsU5ZiGn7XmCS2vI6BAyBKoBDx0Mra/KSUtYOZ4kQ3OVh+bJwMl7nj7JwSl48QCOkQx9Do0diImk7hHOtcph6utqlG+yrpt0fsc7/k5/1nM1ZxlUGvIRQat46s4rQlyLmfbrOjn6CF6lCHpxOKuJVQPAgGHSAjfWW3gJQE+kt4oMB9D+Uk4ee3ciY+5rnvyDyNpaW5crhMIOW8+f/TXy8nctlquldngaA9+so5NqPHFavB7tE= bipul@192.168.0.106"

}

#create instances-1 for VPC

 resource "aws_instance" "mumbai-instance-1" {
  ami           = "ami-0287a05f0ef0e9d9a"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mumbai-key.id
  subnet_id = aws_subnet.ap-south-1a.id
  vpc_security_group_ids = [aws_security_group.allow-ssh-http.id]

  tags = {
    Name = "mumbai-instance-1"
  }
}

#create instances-2 for VPC

 resource "aws_instance" "mumbai-instance-2" {
  ami           = "ami-0287a05f0ef0e9d9a"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mumbai-key.id
  subnet_id = aws_subnet.ap-south-1b.id
  vpc_security_group_ids = [aws_security_group.allow-ssh-http.id]

  tags = {
    Name = "mumbai-instance-2"
  }
}

#create instances-3 with our own AMI

 resource "aws_instance" "mumbai-instance-3" {
  ami           = "ami-0c65d4668e69a09be"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mumbai-key.id
  subnet_id = aws_subnet.ap-south-1b.id
  vpc_security_group_ids = [aws_security_group.allow-ssh-http.id]

  tags = {
    Name = "mumbai-instance-3"
  }
}
# Security Group

resource "aws_security_group" "allow-ssh-http" {
  name        = "allow-ssh-http"
  description = "Allow ssh and http traffic"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    description      = "allow ssh traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
 
  ingress {
    description      = "allow http traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-ssh-http"
  }
}

# create internet gateway

resource "aws_internet_gateway" "IG" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "IG"
  }
}

# create route table for public 

resource "aws_route_table" "public-RT" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG.id
  }

  tags = {
    Name = "public-RT"
  }
}

# create route table for private

resource "aws_route_table" "private-RT" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "private-RT"
  }
}

# Associate RT with public subnet

resource "aws_route_table_association" "ass-public-subnet-1" {
  subnet_id      = aws_subnet.ap-south-1a.id
  route_table_id = aws_route_table.public-RT.id
}

resource "aws_route_table_association" "ass-public-subnet-2" {
  subnet_id      = aws_subnet.ap-south-1b.id
  route_table_id = aws_route_table.public-RT.id
}

# Associate RT with private subnet

resource "aws_route_table_association" "ass-private-subnet" {
  subnet_id      = aws_subnet.ap-south-1c.id
  route_table_id = aws_route_table.private-RT.id
}

# Create Target Group

resource "aws_lb_target_group" "card-website-TG" {
  name     = "card-website-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo_vpc.id
}

# create target group attachment with instances

resource "aws_lb_target_group_attachment" "card-website-TG-att1" {
  target_group_arn = aws_lb_target_group.card-website-TG.arn
  target_id        = aws_instance.mumbai-instance-1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "card-website-TG-att2" {
  target_group_arn = aws_lb_target_group.card-website-TG.arn
  target_id        = aws_instance.mumbai-instance-2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "card-website-TG-att3" {
  target_group_arn = aws_lb_target_group.card-website-TG.arn
  target_id        = aws_instance.mumbai-instance-3.id
  port             = 80
}

# create load balancer

resource "aws_lb" "card-website-lb" {
  name               = "card-website-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow-ssh-http.id]
  subnets            = [aws_subnet.ap-south-1a.id,aws_subnet.ap-south-1b.id]

  tags = {
    Environment = "production"
  }
}

# Listener

resource "aws_lb_listener" "LB-listener" {
  load_balancer_arn = aws_lb.card-website-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.card-website-TG.arn
  }
}

# Lunch Template

resource "aws_launch_template" "demo-template" {
  image_id =  "ami-0287a05f0ef0e9d9a"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mumbai-key.id
  vpc_security_group_ids = [aws_security_group.allow-ssh-http.id]
  user_data = filebase64("example.sh")
  name = "demo-template"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "demo-instance"
    }
  }
}

# ASG

resource "aws_autoscaling_group" "demo-ASG" {
  name                      = "demo-ASG"
  max_size                  = 5
  min_size                  = 2
  desired_capacity          = 4
  vpc_zone_identifier       = [aws_subnet.ap-south-1a.id,aws_subnet.ap-south-1b.id]
  target_group_arns = [aws_lb_target_group.demo-TG.arn]

  launch_template {
    id      = aws_launch_template.demo-template.id
    version = "$Latest"
  }
}

# target group for ASG

resource "aws_lb_target_group" "demo-TG" {
  name     = "demo-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo_vpc.id
}

# create load balancer for asg

resource "aws_lb" "demo-lb" {
  name               = "demo-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow-ssh-http.id]
  subnets            = [aws_subnet.ap-south-1a.id,aws_subnet.ap-south-1b.id]

  tags = {
    Environment = "production"
  }
}

# Listener for ASG

resource "aws_lb_listener" "demo-listener" {
  load_balancer_arn = aws_lb.demo-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo-TG.arn
  }
}

