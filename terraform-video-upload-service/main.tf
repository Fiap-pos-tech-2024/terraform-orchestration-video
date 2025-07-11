terraform {
  backend "s3" {
    bucket = "terraform-states-fiap-20250706"
    key    = "video-upload-service/terraform.tfstate"
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

data "terraform_remote_state" "ecs_shared_role" {
  backend = "s3"
  config = {
    bucket = "terraform-states-fiap-20250706"
    key    = "ecs-shared-role/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "terraform-states-fiap-20250706"
    key    = "video-db/terraform.tfstate"
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

data "aws_ecs_cluster" "this" {
  cluster_name = "microservices-cluster"
}

data "aws_sqs_queue" "video_processing_queue" {
  name = "video-processing-queue"
}

data "aws_sqs_queue" "updated_video_processing_queue" {
  name = "updated-video-processing-queue"
}

# === CloudWatch Log Group ===

resource "aws_cloudwatch_log_group" "video_upload_service" {
  name              = "/ecs/video-upload-service"
  retention_in_days = 7

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

# === Security Group ===

resource "aws_security_group" "ecs_sg" {
  name        = "video-upload-service-ecs-sg"
  description = "Permite acesso HTTP vindo do ALB"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  lifecycle {
    ignore_changes = [egress]
  }

  ingress {
    from_port       = 3003
    to_port         = 3003
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

# === Task Definition ===

resource "aws_ecs_task_definition" "this" {
  family                   = "video-upload-service-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.terraform_remote_state.ecs_shared_role.outputs.ecs_task_execution_role_arn
  task_role_arn            = data.terraform_remote_state.ecs_shared_role.outputs.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "video-upload-service"
      image = "816069165502.dkr.ecr.us-east-1.amazonaws.com/hacka-app-video-upload:latest"
      portMappings = [
        {
          containerPort = 3003
        }
      ],
      environment = [
        { name = "PORT", value = "3003" },
        { name = "MYSQL_URL", value = "mysql://${data.terraform_remote_state.db.outputs.username}:fiap1234@${data.terraform_remote_state.db.outputs.endpoint}/${data.terraform_remote_state.db.outputs.dbname}" },
        { name = "REDIS_HOST", value = "localhost" },
        { name = "REDIS_PORT", value = "6379" },
        { name = "AWS_BUCKET_NAME", value = var.aws_bucket_name },
        { name = "VIDEO_PROCESSING_QUEUE_URL", value = data.aws_sqs_queue.video_processing_queue.url },
        { name = "UPDATED_VIDEO_PROCESSING_QUEUE_URL", value = data.aws_sqs_queue.updated_video_processing_queue.url },
        { name = "BASE_PATH_AUTH", value = "http://${data.terraform_remote_state.alb.outputs.alb_dns_name}/api/auth" }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/video-upload-service"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name  = "redis"
      image = "redis:latest"
      portMappings = [
        {
          containerPort = 6379
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/video-upload-service"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# === ECS Service ===

resource "aws_ecs_service" "this" {
  name            = "video-upload-service"
  cluster         = data.aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.terraform_remote_state.network.outputs.public_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.alb.outputs.video_upload_service_target_group_arn
    container_name   = "video-upload-service"
    container_port   = 3003
  }

  depends_on = [aws_ecs_task_definition.this, data.aws_ecs_cluster.this]
}
