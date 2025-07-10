terraform {
  backend "s3" {
    bucket  = "terraform-states-fiap-20250706"
    key     = "video-processor/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# === Remote States ===

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-states-fiap-20250706"
    key    = "network/terraform.tfstate"
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

data "terraform_remote_state" "video_auth_service" {
  backend = "s3"
  config = {
    bucket = "terraform-states-fiap-20250706"
    key    = "video-auth-service/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "video_storage" {
  backend = "s3"
  config = {
    bucket = "terraform-states-fiap-20250706"
    key    = "bucket-video-storage/terraform.tfstate"
    region = "us-east-1"
  }
}

# === SQS Queues ===

data "aws_sqs_queue" "video_processing_queue" {
  name = "video-processing-queue"
}

data "aws_sqs_queue" "video_processing_dlq" {
  name = "video-processing-dlq"
}

# === IAM Role e Policy para ECS Task ===

resource "aws_iam_role" "video_processor_task_role" {
  name = "video-processor-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "video_processor_task_policy" {
  name = "video-processor-task-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          data.terraform_remote_state.video_storage.outputs.bucket_arn,
          "${data.terraform_remote_state.video_storage.outputs.bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          data.aws_sqs_queue.video_processing_queue.arn,
          data.aws_sqs_queue.video_processing_dlq.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "video_processor_task_policy" {
  role       = aws_iam_role.video_processor_task_role.name
  policy_arn = aws_iam_policy.video_processor_task_policy.arn
}

# === CloudWatch Log Group ===

resource "aws_cloudwatch_log_group" "video_processor" {
  name              = "/ecs/video-processor"
  retention_in_days = 7

  tags = {
    Name        = "Video Processor Logs"
    Environment = "production"
    Service     = "video-processor"
  }
}

# === Security Group para ECS ===

resource "aws_security_group" "ecs_sg" {
  name        = "video-processor-ecs-sg"
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

  tags = {
    Name        = "Video Processor ECS Security Group"
    Environment = "production"
    Service     = "video-processor"
  }
}

# === ECS Task Definition ===

resource "aws_ecs_task_definition" "this" {
  family                   = "video-processor-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = data.terraform_remote_state.video_auth_service.outputs.ecs_task_execution_role_arn
  task_role_arn            = aws_iam_role.video_processor_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "video-processor"
      image = "816069165502.dkr.ecr.us-east-1.amazonaws.com/video-processor:latest"
      portMappings = [
        {
          containerPort = 3000
        }
      ],
      environment = [
        { name = "PORT", value = "3000" },
        { name = "AWS_REGION", value = "us-east-1" },
        { name = "S3_BUCKET", value = data.terraform_remote_state.video_storage.outputs.bucket_name },
        { name = "SQS_QUEUE_URL", value = data.aws_sqs_queue.video_processing_queue.url },
        { name = "NODE_ENV", value = "production" }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/video-processor"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "Video Processor Task Definition"
    Environment = "production"
    Service     = "video-processor"
  }
}

# === ECS Service ===

resource "aws_ecs_service" "this" {
  name            = "video-processor"
  cluster         = data.terraform_remote_state.video_auth_service.outputs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.terraform_remote_state.network.outputs.public_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.alb.outputs.video_processor_target_group_arn
    container_name   = "video-processor"
    container_port   = 3000
  }

  depends_on = [aws_ecs_task_definition.this]

  tags = {
    Name        = "Video Processor Service"
    Environment = "production"
    Service     = "video-processor"
  }
}
