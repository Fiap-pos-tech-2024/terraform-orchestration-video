terraform {
  backend "s3" {
    bucket = "terraform-states-fiap-20250706"
    key    = "queues/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_sqs_queue" "video_processing_queue" {
  name                      = "video-processing-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 300

  tags = {
    Name        = "Video Processing Queue"
    Environment = "production"
    Service     = "video-processor"
  }
}

resource "aws_sqs_queue" "video_processing_dlq" {
  name = "video-processing-dlq"

  tags = {
    Name        = "Video Processing Dead Letter Queue"
    Environment = "production"
    Service     = "video-processor"
  }
}

resource "aws_sqs_queue_redrive_policy" "video_processing_queue" {
  queue_url = aws_sqs_queue.video_processing_queue.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.video_processing_dlq.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue" "updated_video_processing_queue" {
  name = "updated-video-processing-queue"
  delay_seconds = 0
  max_message_size = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30

  tags = {
    Name = "updated-video-processing-queue"
  }
}