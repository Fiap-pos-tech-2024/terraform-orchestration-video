output "user_pool_id" {
  description = "ID do Cognito User Pool"
  value       = aws_cognito_user_pool.video_pool.id
}

output "user_pool_client_id" {
  description = "ID do Cognito App Client"
  value       = aws_cognito_user_pool_client.video_pool_client.id
}