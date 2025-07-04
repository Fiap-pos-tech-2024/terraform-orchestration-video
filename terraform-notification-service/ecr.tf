resource "aws_ecr_repository" "notification_service" {
  name                 = "notification-service"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = "production"
  }
}
