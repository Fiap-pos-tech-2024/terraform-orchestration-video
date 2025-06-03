output "endpoint" {
  description = "Endpoint completo (host:port) do RDS"
  value       = aws_db_instance.pedido.endpoint
}

output "port" {
  description = "Porta do RDS"
  value       = aws_db_instance.pedido.port
}

output "username" {
  description = "Usuário do banco"
  value       = aws_db_instance.pedido.username
}

output "dbname" {
  description = "Schema do banco"
  value       = aws_db_instance.pedido.db_name
}

output "security_group_id" {
  description = "ID do Security Group do Pedido RDS"
  value       = aws_security_group.pedido_db_sg.id
}

output "subnet_group_name" {
  description = "Nome do DB Subnet Group"
  value       = aws_db_subnet_group.pedido.name
}
