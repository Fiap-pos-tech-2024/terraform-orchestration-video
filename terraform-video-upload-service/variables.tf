variable "account_id" {
  description = "ID da conta AWS"
  type        = string
  default     = "816069165502"  
}

variable "aws_bucket_name" {
  description = "Nome do bucket S3 para armazenamento de vídeos e zips"
  type        = string
  default     = "fiap-video-bucket-20250706"
}
