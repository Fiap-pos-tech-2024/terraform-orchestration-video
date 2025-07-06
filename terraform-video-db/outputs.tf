output "endpoint" {
  description = "Endpoint do RDS (host)"
  value       = aws_db_instance.video.endpoint
}

output "port" {
  description = "Porta do RDS"
  value       = aws_db_instance.video.port
}

output "username" {
  description = "Usuário do banco"
  value       = aws_db_instance.video.username
}

output "dbname" {
  description = "Nome do schema"
  value       = aws_db_instance.video.db_name
}

output "security_group_id" {
  description = "Security Group criado para o RDS"
  value       = aws_security_group.video_db_sg.id
}
