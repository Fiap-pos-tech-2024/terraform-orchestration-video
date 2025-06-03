output "alb_dns_name" {
  description = "DNS público do Load Balancer"
  value       = aws_lb.main.dns_name
}

output "cliente_service_target_group_arn" {
  description = "ARN do Target Group do cliente-service"
  value       = aws_lb_target_group.cliente_service.arn
}

output "alb_security_group_id" {
  description = "Security group do ALB (usado no ECS para liberar entrada)"
  value       = aws_security_group.alb_sg.id
}

output "pedido_service_target_group_arn" {
  description = "ARN do Target Group do pedido-service"
  value       = aws_lb_target_group.pedido_service.arn
}

output "pagamento_service_target_group_arn" {
  description = "ARN do Target Group do pagamento-service"
  value       = aws_lb_target_group.pagamento_service.arn
}
