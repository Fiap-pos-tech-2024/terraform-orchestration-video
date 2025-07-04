terraform {
  backend "s3" {
    bucket = "terraform-states-816069165502"
    key    = "notification-service/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# === Remote states ===

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-states-816069165502"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = "terraform-states-816069165502"
    key    = "alb/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "video_auth_service" {
  backend = "s3"
  config = {
    bucket = "terraform-states-816069165502"
    key    = "video-auth-service/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_cloudwatch_log_group" "notification_service" {
  name              = "/ecs/notification-service"
  retention_in_days = 7
}

resource "aws_security_group" "ecs_notification_sg" {
  name        = "notification-service-ecs-sg"
  description = "Permite acesso HTTP vindo do ALB"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.alb.outputs.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "notification_service" {
  family                   = "notification-service-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.terraform_remote_state.video_auth_service.outputs.ecs_task_execution_role_arn
  task_role_arn            = data.terraform_remote_state.video_auth_service.outputs.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "notification-service"
      image = "816069165502.dkr.ecr.us-east-1.amazonaws.com/notification-service:latest"
      portMappings = [
        {
          containerPort = 3001
        }
      ],
      environment = [
        { name = "PORT", value = "3001" },
        { name = "NODE_ENV", value = "production" },
        { name = "SMTP_HOST", value = var.smtp_host },
        { name = "SMTP_PORT", value = tostring(var.smtp_port) },
        { name = "SMTP_USER", value = var.smtp_user },
        { name = "SMTP_PASS", value = var.smtp_pass },
        { name = "FROM_EMAIL", value = var.from_email },
        { name = "FROM_NAME", value = var.from_name }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/notification-service"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "notification_service" {
  name            = "notification-service"
  cluster         = data.terraform_remote_state.video_auth_service.outputs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.notification_service.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.terraform_remote_state.network.outputs.public_subnet_ids
    security_groups  = [aws_security_group.ecs_notification_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:816069165502:targetgroup/notification-tg-v2/c46a86aeae3a6a45"
    container_name   = "notification-service"
    container_port   = 3001
  }

  depends_on = [aws_ecs_task_definition.notification_service]
}
