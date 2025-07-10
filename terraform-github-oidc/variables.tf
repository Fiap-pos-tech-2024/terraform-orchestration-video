variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "services" {
  description = "Lista de microsserviços com seus repositórios GitHub"
  type = map(object({
    repository = string
  }))
  default = {
    # ex1-service = {
    #   repository = "Fiap-pos-tech-2024/ex1-service"
    # },
    # ex2-service = {
    #   repository = "Fiap-pos-tech-2024/ex2-service"
    # },
    # ex3-service = {
    #   repository = "Fiap-pos-tech-2024/ex3-service"
    # },
    video-auth-service = {
      repository = "Fiap-pos-tech-2024/video-auth-service"
    },
    notification-service = {
      repository = "Fiap-pos-tech-2024/hacka-app-video-notification"
    },
    video-upload-service = {
      repository = "Fiap-pos-tech-2024/hacka-app-video-upload"
    },
    video-processor-service = {
      repository = "Fiap-pos-tech-2024/hacka-app-video-processor"
    }
  }
}
