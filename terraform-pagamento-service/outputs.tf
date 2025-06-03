output "pagamento_service_url" {
  description = "URL do pagamento-service via ALB"
  value       = "http://${data.terraform_remote_state.alb.outputs.alb_dns_name}/pagamentos"
}

output "pagamento_service_target_group_arn" {
  description = "ARN do Target Group do pagamento-service vindo do ALB remoto"
  value       = data.terraform_remote_state.alb.outputs.pagamento_service_target_group_arn
}

output "ecr_image" {
  description = "Imagem usada no ECS"
  value       = var.ecr_image_url
}
