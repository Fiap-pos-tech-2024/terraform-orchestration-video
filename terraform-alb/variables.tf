variable "region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID da VPC onde o ALB será criado"
  type        = string
}

variable "public_subnet_ids" {
  description = "Lista de subnets públicas para o ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group que será associado ao ALB"
  type        = string
}
