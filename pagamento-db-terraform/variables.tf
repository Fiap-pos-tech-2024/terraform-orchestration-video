variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "table_name" {
  description = "Nome da tabela DynamoDB de pagamento"
  type        = string
  default     = "Pagamentos"
}

variable "hash_key_name" {
  description = "Nome do atributo chave primária (partition key)"
  type        = string
  default     = "pedidoId"
}

variable "hash_key_type" {
  description = "Tipo do atributo chave primária (S = string, N = number)"
  type        = string
  default     = "S"
}

variable "environment" {
  description = "Ambiente (tag)"
  type        = string
  default     = "dev"
}
