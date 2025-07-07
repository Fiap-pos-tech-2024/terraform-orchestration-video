terraform {
  backend "s3" {
    bucket = "terraform-states-fiap-20250706"
    key    = "alb/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-states-fiap-20250706"

    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB - libera porta 80"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

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
    Name = "alb-sg"
  }
}

resource "aws_lb" "main" {
  name               = "ms-shared-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_ids
  enable_deletion_protection = false
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# Target group para video-auth-service
resource "aws_lb_target_group" "video_auth_service" {
  name        = "video-auth-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener rule para video-auth-service
resource "aws_lb_listener_rule" "video_auth_service_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.video_auth_service.arn
  }

  condition {
    path_pattern {
      values = ["/auth-docs*", "/api/auth*", "/api/usuarios*", "/health", "/auth-metrics"]
    }
  }
}

# Target group para notification-service
resource "aws_lb_target_group" "notification_service" {
  name        = "notification-tg"
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api/notifications/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener rule para notification-service
resource "aws_lb_listener_rule" "notification_service_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.notification_service.arn
  }

  condition {
    path_pattern {
      values = ["/notification-docs*", "/api/notify*", "/api/notifications/health", "/notification-metrics"]
    }
  }
}


# Target group para video-processor
resource "aws_lb_target_group" "video_processor" {
  name        = "video-processor-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200,404"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener rule para video-processor
resource "aws_lb_listener_rule" "video_processor_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.video_processor.arn
  }

  condition {
    path_pattern {
      values = ["/processor*", "/api/video*", "/video-docs*"]
    }
  }
}

# Target group para video-upload-service
resource "aws_lb_target_group" "video_upload_service" {
  name        = "video-upload-tg"
  port        = 3003
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener rule para video-upload-service
resource "aws_lb_listener_rule" "video_upload_service_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.video_upload_service.arn
  }

  condition {
    path_pattern {
      values = ["/video-upload-app/*"]
    }
  }
}

