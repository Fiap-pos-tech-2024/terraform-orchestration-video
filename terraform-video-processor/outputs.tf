output "s3_bucket_name" {
  description = "Nome do bucket S3 para armazenamento de vídeos"
  value       = aws_s3_bucket.video_processor_storage.bucket
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3 para armazenamento de vídeos"
  value       = aws_s3_bucket.video_processor_storage.arn
}

output "sqs_queue_url" {
  description = "URL da fila SQS para processamento de vídeos"
  value       = aws_sqs_queue.video_processing_queue.url
}

output "sqs_queue_arn" {
  description = "ARN da fila SQS para processamento de vídeos"
  value       = aws_sqs_queue.video_processing_queue.arn
}

output "sqs_dlq_url" {
  description = "URL da fila DLQ SQS"
  value       = aws_sqs_queue.video_processing_dlq.url
}

output "sqs_dlq_arn" {
  description = "ARN da fila DLQ SQS"
  value       = aws_sqs_queue.video_processing_dlq.arn
}

output "ecs_service_name" {
  description = "Nome do serviço ECS"
  value       = aws_ecs_service.this.name
}

output "ecs_task_definition_arn" {
  description = "ARN da task definition do ECS"
  value       = aws_ecs_task_definition.this.arn
}

output "video_processor_task_role_arn" {
  description = "ARN da IAM role da task do video processor"
  value       = aws_iam_role.video_processor_task_role.arn
}
