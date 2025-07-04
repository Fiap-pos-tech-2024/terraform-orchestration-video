output "notification_service_arn" {
  description = "ARN do serviço ECS do notification service"
  value       = aws_ecs_service.notification_service.id
}

output "notification_task_definition_arn" {
  description = "ARN da task definition do notification service"
  value       = aws_ecs_task_definition.notification_service.arn
}

output "notification_security_group_id" {
  description = "ID do security group do notification service"
  value       = aws_security_group.ecs_notification_sg.id
}
