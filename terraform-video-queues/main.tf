terraform {
  backend "s3" {
    bucket = "terraform-states-816069165502"
    key    = "queues/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_sqs_queue" "uploaded_video_queue" {
  name = "uploaded-video-queue"
  delay_seconds = 0
  max_message_size = 262144
  message_retention_seconds = 86400
  receive_wait_time_seconds = 0
  visibility_timeout_seconds = 30

  tags = {
    Name = "uploaded-video-queue"
  }
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