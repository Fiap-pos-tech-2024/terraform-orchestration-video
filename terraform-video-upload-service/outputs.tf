output "video_upload_service_url" {
  description = "URL externa via ALB"
  value       = "http://${data.terraform_remote_state.alb.outputs.alb_dns_name}/video-upload-app/docs"
}
