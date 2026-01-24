
# ---------------------------------------------
# VPC
# ---------------------------------------------
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "demo-main-vpc"
  }
}

# ---------------------------------------------
# Internet Gateway
# ---------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "demo-igw"
  }
}

# ---------------------------------------------
# Public Subnets (Multi-AZ)
# ---------------------------------------------
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "demo-public-subnet-ap-south-1a"
  }
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "demo-public-subnet-ap-south-1b"
  }
}

# ---------------------------------------------
# Route Table for Public Subnets
# ---------------------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "demo-public-rt"
  }
}

# ---------------------------------------------
# Route Table Associations
# ---------------------------------------------
resource "aws_route_table_association" "public_rt_assoc_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_rt.id
}

# ---------------------------------------------
# Security Group - ALB
# ---------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "demo-alb-sg"
  description = "Allow HTTP traffic from internet"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-alb-sg"
  }
}

# ---------------------------------------------
# Security Group - EC2
# ---------------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "demo-web-sg"
  description = "Allow HTTP from ALB and SSH access"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-web-sg"
  }
}

# ---------------------------------------------
# EC2 Instance (Web Server)
# ---------------------------------------------
resource "aws_instance" "web_server" {
  ami                         = "ami-01760eea5c574eb86"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet_az1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  user_data                   = file("install_nginx.sh")

  tags = {
    Name = "demo-nginx-web-server"
  }
}

# ---------------------------------------------
# Application Load Balancer
# ---------------------------------------------
resource "aws_lb" "app_alb" {
  name               = "demo-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_subnet_az1.id,
    aws_subnet.public_subnet_az2.id
  ]

  tags = {
    Name = "demo-app-alb"
  }
}

# ---------------------------------------------
# Target Group
# ---------------------------------------------
resource "aws_lb_target_group" "web_tg" {
  name     = "demo-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "demo-web-target-group"
  }
}

# ---------------------------------------------
# Target Group Attachment
# ---------------------------------------------
resource "aws_lb_target_group_attachment" "web_tg_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}

# ---------------------------------------------
# Listener
# ---------------------------------------------
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
