terraform {
  backend "s3" {
    bucket = "terraform-states-fiap-20250706"
    key    = "video-auth-service/terraform.tfstate"
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
    bucket = "terraform-states-fiap-20250706"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cognito" {
  backend = "s3"
  config = {
    bucket = "terraform-states-fiap-20250706"
    key    = "cognito/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "terraform-states-fiap-20250706"
    key    = "user-db/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = "terraform-states-fiap-20250706"
    key    = "alb/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_ecs_cluster" "this" {
  name = "microservices-cluster"
}

resource "aws_cloudwatch_log_group" "video_auth_service" {
  name              = "/ecs/video-auth-service"
  retention_in_days = 7
}

resource "aws_security_group" "ecs_sg" {
  name        = "video-auth-service-ecs-sg"
  description = "Permite acesso HTTP vindo do ALB"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
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

resource "aws_ecs_task_definition" "this" {
  family                   = "video-auth-service-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "video-auth-service"
      image = "816069165502.dkr.ecr.us-east-1.amazonaws.com/video-auth-service:latest"
      portMappings = [
        {
          containerPort = 3000
        }
      ],
      environment = [
        { name = "PORT", value = "3000" },
        { name = "MYSQL_HOST", value = split(":", data.terraform_remote_state.db.outputs.endpoint)[0] },
        { name = "MYSQL_PORT", value = tostring(data.terraform_remote_state.db.outputs.port) },
        { name = "MYSQL_USER", value = data.terraform_remote_state.db.outputs.username },
        { name = "MYSQL_PASSWORD", value = "fiap1234" },
        { name = "MYSQL_DATABASE", value = data.terraform_remote_state.db.outputs.dbname },
        { name = "COGNITO_USER_POOL_ID", value = data.terraform_remote_state.cognito.outputs.user_pool_id },
        { name = "COGNITO_CLIENT_ID", value = data.terraform_remote_state.cognito.outputs.user_pool_client_id },
        { name = "SWAGGER_URL", value = "http://${data.terraform_remote_state.alb.outputs.alb_dns_name}/api" },
        { name = "NODE_ENV", value = "production" }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/video-auth-service"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "video-auth-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.terraform_remote_state.network.outputs.public_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.alb.outputs.video_auth_service_target_group_arn
    container_name   = "video-auth-service"
    container_port   = 3000
  }

  depends_on = [aws_ecs_task_definition.this]
}
