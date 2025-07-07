variable "account_id" {
  description = "ID da conta AWS"
  type        = string
  default     = "835311494914"  
}

variable "execution_role_arn" {
  type = string
  default = "arn:aws:iam::835311494914:role/LabRole"
}

variable "aws_bucket_name" {
  description = "Nome do bucket S3 para armazenamento de vídeos e zips"
  type        = string
  default     = "fiap-video-bucket"
}
