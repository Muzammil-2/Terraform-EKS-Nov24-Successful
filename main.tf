provider "aws" {
  region = "ap-south-1"
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"


  tags = {
    Name = "subnet-1"
  }
}
# resource "aws_subnet" "sub2" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.2.0/24"
#   availability_zone       = "ap-south-1b"
#   map_public_ip_on_launch = true

#   tags = {

#     name = "subnet-2"
#   }
# }
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "iwg-main"
  }
}

resource "aws_route_table" "RT01" {
  vpc_id = aws_vpc.main.id
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "RTA" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT01.id
#  gateway_id     = aws_internet_gateway.gw.id
}
# security group
resource "aws_security_group" "sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "main-sg"
  }

 ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "HTTP from VPC"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# resource "aws_key_pair" "mykey" {
#   key_name = "my-key-pair"
#   public_key = file("./ir.pem")
  
# }
resource "aws_instance" "example1" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.sub1.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name = "irfan_pem_key"
#  user_data              = base64encode(file("userdata.sh"))
  count = 3
  tags = {
    Name = var.ec2_name[count.index]
  }
}
# resource "aws_instance" "example2" {
#   ami           = "ami-0ad21ae1d0696ad58"
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.sub2.id
#   associate_public_ip_address = true
#   vpc_security_group_ids = [aws_security_group.sg.id]
#   user_data              = base64encode(file("userdata.sh"))

#   tags = {
#     Name = "tf-server-2"
#   }
# }
# create aws elb
# resource "aws_lb" "my-elb" {
#   name               = "lb-tf"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.sg.id]
#   subnets            = [aws_subnet.sub1.id,aws_subnet.sub2.id]


#   tags = {
#     Environment = "production-elb"
#   }
# }

# target group
# resource "aws_lb_target_group" "elb-tg" {
#   name     = "tf-lb-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main.id
#  health_check {
#     path = "/"
#     port = "traffic-port"
#   }
# }


# resource "aws_lb_target_group_attachment" "elb-tg-at1" {
#   target_group_arn = aws_lb_target_group.elb-tg.arn
#   target_id        = aws_instance.example1.id
#   port             = 80
# }
# resource "aws_lb_target_group_attachment" "elb-tg-at2" {
#   target_group_arn = aws_lb_target_group.elb-tg.arn
#   target_id        = aws_instance.example2.id
#   port             = 80
# }
# # elb listner
# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.my-elb.arn
#   port              = "80"
#   protocol          = "HTTP"
#   #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
#  # alpn_policy       = "HTTP2Preferred"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.elb-tg.arn
#   }
# }
# output "loadbalancerdns" {
#   value = aws_lb.my-elb.dns_name
# }
