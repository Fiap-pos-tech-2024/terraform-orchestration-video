output "table_name" {
  description = "Nome da tabela DynamoDB criada"
  value       = aws_dynamodb_table.pagamento.name
}

output "table_arn" {
  description = "ARN da tabela DynamoDB"
  value       = aws_dynamodb_table.pagamento.arn
}
