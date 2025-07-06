terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

variable "account_id" {
  description = "ID da conta AWS"
  type        = string
  default     = "816069165502"  
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "GB de armazenamento"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "Usuário do banco"
  type        = string
  default     = "fiap"
}

variable "db_video_name" {
  description = "Nome do schema"
  type        = string
  default     = "videodb"
}

variable "db_password" {
  description = "Senha do banco"
  type        = string
  default     = "fiap1234" 
}

