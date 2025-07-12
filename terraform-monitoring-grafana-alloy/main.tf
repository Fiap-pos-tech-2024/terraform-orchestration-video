terraform {
  backend "s3" {
    bucket  = "terraform-states-fiap-20250706"
    key     = "monitoring-grafana-alloy/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

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

data "terraform_remote_state" "video_auth_service" {
  backend = "s3"
  config = {
    bucket = "terraform-states-fiap-20250706"
    key    = "video-auth-service/terraform.tfstate"
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


resource "aws_cloudwatch_log_group" "grafana_alloy" {
  name              = "/ecs/grafana-alloy"
  retention_in_days = 7
}

resource "aws_security_group" "alloy_sg" {
  name        = "alloy-sg"
  description = "Allows outbound traffic to Grafana Cloud"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 12345
    to_port     = 12345
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_ecs_task_definition" "grafana_alloy" {
  family                   = "grafana-alloy"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = data.terraform_remote_state.ecs_shared_role.outputs.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "grafana-alloy"
      image = "816069165502.dkr.ecr.us-east-1.amazonaws.com/grafana-alloy:latest"
      portMappings = [
        {
          containerPort = 12345
          protocol      = "tcp"
        }
      ],
      essential = true,
      command   = ["run", "/etc/alloy/alloy-config.river"],
      environment = [
        { name = "GRAFANA_REMOTE_WRITE_URL", value = var.grafana_remote_write_url },
        { name = "GRAFANA_USERNAME", value = var.grafana_username },
        { name = "GRAFANA_PASSWORD", value = var.grafana_password },
        { name = "SHARED_ALB_DNS", value = data.terraform_remote_state.alb.outputs.alb_dns_name }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.grafana_alloy.name,
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "ecs"
        }
      },

    }
  ])
  depends_on = [aws_cloudwatch_log_group.grafana_alloy]
}

resource "aws_ecs_service" "grafana_alloy" {
  name            = "grafana-alloy"
  cluster         = data.terraform_remote_state.video_auth_service.outputs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana_alloy.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.terraform_remote_state.network.outputs.public_subnet_ids
    security_groups  = [aws_security_group.alloy_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.grafana_alloy]
}
