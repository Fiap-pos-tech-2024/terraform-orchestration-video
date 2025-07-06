variable "execution_role_arn" {
  type = string
  default = "arn:aws:iam::835311494914:role/LabRole"
}

variable "account_id" {
  description = "ID da conta AWS"
  type        = string
  default     = "816069165502"  
}

variable "AWS_BUCKET_NAME" {
  description = "Nome do bucket S3 para upload de vídeos"
  type        = string
  default     = "fiap-video-upload-bucket"
}
variable "UPLOADED_VIDEO_QUEUE_URL" {
  description = "URL da fila SQS para vídeos enviados"
  type        = string
  default     = "https://sqs.us-east-1.amazonaws.com/835311494914/uploaded-video-queue"
}

variable "UPDATED_VIDEO_PROCESSING_QUEUE_URL" {
  description = "URL da fila SQS para vídeos processados"
  type        = string
  default     = "https://sqs.us-east-1.amazonaws.com/835311494914/updated-video-processing-queue"
}
