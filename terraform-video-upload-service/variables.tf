variable "account_id" {
  description = "ID da conta AWS"
  type        = string
  default     = "816069165502"  
}

variable "execution_role_arn" {
  type = string
  default = "arn:aws:iam::816069165502:role/ecsTaskExecutionRole"
}

variable "aws_bucket_name" {
  description = "Nome do bucket S3 para armazenamento de vídeos e zips"
  type        = string
  default     = "fiap-video-bucket-20250706"
}
