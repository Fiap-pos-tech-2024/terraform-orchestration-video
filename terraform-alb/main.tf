provider "aws" {
  region = var.region
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB - libera porta 80"
  vpc_id      = var.vpc_id

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
  subnets            = var.public_subnet_ids
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

# Target group cliente-service
resource "aws_lb_target_group" "cliente_service" {
  name        = "cliente-service-tg"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
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
# Regra para cliente-service
resource "aws_lb_listener_rule" "cliente_service_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cliente_service.arn
  }

  condition {
    path_pattern {
      values = ["/cliente-docs*", "/api/auth*", "/api/clientes*"]
    }
  }
}

# Target group pedido-service
resource "aws_lb_target_group" "pedido_service" {
  name        = "pedido-service-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
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

# Regra para pedido-service
resource "aws_lb_listener_rule" "pedido_service_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pedido_service.arn
  }

  condition {
    path_pattern {
      values = ["/pedido-docs*", "/api/pedidos*", "/api/produtos*", "/health"]
    }
  }
}

# Target group para pagamento-service
resource "aws_lb_target_group" "pagamento_service" {
  name        = "pagamento-service-tg"
  port        = 5001
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
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

# Regra para pagamento-service
resource "aws_lb_listener_rule" "pagamento_service_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pagamento_service.arn
  }

  condition {
    path_pattern {
      values = ["/pagamento-docs*", "/api/pagamento*", "/api/auth*", "/health"]
    }
  }
}
