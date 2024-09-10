provider "aws" {
  region = "us-west-2"  # Update to your preferred region
}

# S3 Backend for Terraform State
terraform {
  backend "s3" {
    bucket         = "simulated-robot-terraform"
    key            = "simulated-robot/terraform.tfstate"
    region         = "us-west-2"  # Update to your preferred region
    encrypt        = true
  }
}

# IAM Role for ECS Task Execution
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

# VPC Setup
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "ecs-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "ecs-vpc"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
}

# ECS Task Definition for controller
resource "aws_ecs_task_definition" "controller" {
  family                   = "controller-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "controller"
      image     = var.ecr_controller_image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [{
        containerPort = 5000
        hostPort      = 5000
      }]
    }
  ])
}

# ECS Task Definition for simulated_robot
resource "aws_ecs_task_definition" "simulated_robot" {
  family                   = "simulated-robot-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "simulated_robot"
      image     =var.ecr_simulated_robot_image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [{
        containerPort = 8888
        hostPort      = 8888
      }]
    }
  ])
}

# ECS Service for controller
resource "aws_ecs_service" "controller_service" {
  name            = "controller-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.controller.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.public_subnets
    security_groups = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.controller_tg.arn
    container_name   = "controller"
    container_port   = 5000
  }
}

# ECS Service for simulated_robot
resource "aws_ecs_service" "simulated_robot_service" {
  name            = "simulated-robot-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.simulated_robot.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_service_sg.id]
  }
}

# Network Load Balancer for controller
resource "aws_lb" "controller_nlb" {
  name               = "controller-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "controller_tg" {
  name        = "controller-tg"
  port        = 5000
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    interval            = 30
    protocol            = "TCP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "controller_listener" {
  load_balancer_arn = aws_lb.controller_nlb.arn
  port              = 5000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller_tg.arn
  }
}

# Security Group for ECS Services
resource "aws_security_group" "ecs_service_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5000
    to_port     = 5000
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
    Name = "ecs-service-sg"
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "lb_sg" {
  vpc_id = module.vpc.vpc_id

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
    Name = "lb-sg"
  }
}

# Route53 DNS
resource "aws_route53_record" "controller_dns" {
  zone_id = data.aws_route53_zone.andrewjacksonio.zone_id
  name    = "robot-controller.andrewjackson.io"
  type    = "A"

  alias {
    name                   = aws_lb.controller_nlb.dns_name
    zone_id                = aws_lb.controller_nlb.zone_id
    evaluate_target_health = true
  }
}

# Existing Route53 Zone
data "aws_route53_zone" "andrewjacksonio" {
  name         = "andrewjackson.io"
  private_zone = false
}