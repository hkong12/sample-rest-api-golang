# This file is used for terraform to provision aws resources

provider "aws" {
    region = "ap-southeast-1"
}

locals {
    vpc_cidr_block = "10.0.0.0/16"
    public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

# The VPC that the ECS cluster is deployed to
resource "aws_vpc" "main" {
  cidr_block            = local.vpc_cidr_block
  instance_tenancy      = "default"
  enable_dns_hostnames  = true

  tags = {
    Project = "sample-api"
  }
}

# Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Project = "sample-api"
  }
}

# Get reference for AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Public subnets
resource "aws_subnet" "public" {
  count             = length(local.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Project = "sample-api"
  }
}

# Private subnets
resource "aws_subnet" "private" {
  count             = length(local.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Project = "sample-api"
  }
}

# EIP attached to NAT gateway
resource "aws_eip" "nat" {
  count    = length(local.public_subnet_cidrs)
  vpc      = true
}

# NAT gateway in public subnets
resource "aws_nat_gateway" "gw" {
  count         = length(local.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
      Project = "sample-api"
  }
}

# Public routing table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "sample-api"
  }
}

# Private routing table
resource "aws_route_table" "private" {
  count = length(local.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.gw[count.index].id
  }

  tags = {
    Name = "sample-api"
  }
}

# Routing table association to public subnets
resource "aws_route_table_association" "public" {
  count          = length(local.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Routing table association to public subnets
resource "aws_route_table_association" "private" {
  count          = length(local.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Security group for internet-facing load balancer
resource "aws_security_group" "lb_sg" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }
}

# internet-facing load balancer
resource "aws_lb" "alb" {
  name               = "sample-api-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public.*.id

  tags = {
    Project = "sample-api"
  }
}

# Load balancer target group
resource "aws_lb_target_group" "target" {
  name     = "sample-api-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  health_check {
    interval    = 6
    path        = "/health"
    timeout     = 5
  }

  tags = {
      Project = "sample-api"
  }
}

# Load balancer listener
resource "aws_lb_listener" "ll" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target.id
    type             = "forward"
  }
}

# ECS cluster
resource "aws_ecs_cluster" "ecs" {
  name = "sample-api-cluster"

  tags = {
      Project = "sample-api"
  }
}

# ECS service security group
resource "aws_security_group" "ecs_sg" {
  name        = "private_subnet"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.public_subnet_cidrs
  }

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS service
resource "aws_ecs_service" "api" {
  name            = "sample"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.target.arn
    container_name   = "api"
    container_port   = 80
  }

  network_configuration {
    subnets = aws_subnet.private.*.id
    security_groups = [ aws_security_group.ecs_sg.id ] 
  }
}

# ECS task definition
resource "aws_ecs_task_definition" "api" {
  family                = "sample-api"
  container_definitions = <<TASK_DEFINITION
[
    {
      "name": "api",
      "image": "xueerk/sample-api:8",
      "cpu": 10,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
]
TASK_DEFINITION
  network_mode          = "awsvpc"
  requires_compatibilities = [ "FARGATE" ]
  cpu = 256
  memory = 512
}

# Output the URL of the ALB
output "load_balancer_url" {
  value = aws_lb.alb.dns_name
}