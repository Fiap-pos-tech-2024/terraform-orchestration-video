output "bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
}

output "bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}
