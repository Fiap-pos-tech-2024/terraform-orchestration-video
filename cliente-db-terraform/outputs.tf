output "endpoint" {
  description = "Endpoint do RDS (host)"
  value       = aws_db_instance.cliente.endpoint
}

output "port" {
  description = "Porta do RDS"
  value       = aws_db_instance.cliente.port
}

output "username" {
  description = "Usuário do banco"
  value       = aws_db_instance.cliente.username
}

output "dbname" {
  description = "Nome do schema"
  value       = aws_db_instance.cliente.db_name
}

output "security_group_id" {
  description = "Security Group criado para o RDS"
  value       = aws_security_group.cliente_db_sg.id
}
