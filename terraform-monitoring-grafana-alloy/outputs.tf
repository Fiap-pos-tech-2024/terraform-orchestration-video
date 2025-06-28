output "alloy_task_arn" {
  value       = aws_ecs_task_definition.grafana_alloy.arn
  description = "ARN da task definition do Alloy"
}

output "alloy_service_name" {
  value       = aws_ecs_service.grafana_alloy.name
  description = "Nome do serviço ECS do Alloy"
}
