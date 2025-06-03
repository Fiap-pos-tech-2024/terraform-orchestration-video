output "cliente_service_url" {
  description = "URL do cliente-service via ALB"
  value       = "http://${data.terraform_remote_state.alb.outputs.alb_dns_name}/clientes"
}



output "cliente_service_target_group_arn" {
  description = "ARN do Target Group do cliente-service vindo do ALB remoto"
  value       = data.terraform_remote_state.alb.outputs.cliente_service_target_group_arn
}

output "ecr_image" {
  description = "Imagem usada no ECS"
  value       = var.ecr_image_url
}
