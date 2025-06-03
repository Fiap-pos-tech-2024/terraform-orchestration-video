variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID da VPC (do network-terraform)"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnets para o RDS (do network-terraform)"
  type        = list(string)
}

variable "instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Armazenamento (GB)"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "Usuário do banco"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Senha do banco"
  type        = string
}

variable "db_name" {
  description = "Nome do schema"
  type        = string
  default     = "pedidos"
}
