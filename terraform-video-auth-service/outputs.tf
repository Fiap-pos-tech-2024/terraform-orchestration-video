output "video_auth_service_url" {
  description = "URL externa via ALB"
  value       = "http://${data.terraform_remote_state.alb.outputs.alb_dns_name}/auth-docs"
}

output "ecs_task_execution_role_arn" {
  description = "ARN da role usada pelas ECS tasks"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_cluster_id" {
  description = "ID do ECS Cluster"
  value       = aws_ecs_cluster.this.id
}
