output "alb_dns_name" {
  description = "DNS público do Load Balancer"
  value       = aws_lb.main.dns_name
}

output "video_auth_service_target_group_arn" {
  description = "ARN do Target Group do video-auth-service"
  value       = aws_lb_target_group.video_auth_service.arn
}

output "alb_security_group_id" {
  description = "Security group do ALB (usado no ECS para liberar entrada)"
  value       = aws_security_group.alb_sg.id
}

output "alb_listener_arn" {
  description = "ARN do listener HTTP (porta 80) do ALB"
  value       = aws_lb_listener.http.arn
}

output "notification_service_target_group_arn" {
  description = "ARN do Target Group do notification-service"
  value       = aws_lb_target_group.notification_service.arn
}
