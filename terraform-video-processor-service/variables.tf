# Todas as variáveis necessárias são obtidas via remote state
# Não são necessárias variáveis adicionais
variable "aws_bucket_name" {
  description = "Nome do bucket S3 para armazenamento de vídeos e zips"
  type        = string
  default     = "fiap-video-bucket-20250706"
}