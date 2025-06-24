variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Número de Availability Zones a usar para subnets públicas"
  type        = number
  default     = 2
}

variable "name_prefix" {
  description = "Prefixo para nomear recursos"
  type        = string
  default     = "appnet"
}
