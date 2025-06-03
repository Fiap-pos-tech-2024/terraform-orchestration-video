variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "ecr_image_url" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
}

variable "cognito_client_id" {
  type = string
}

variable "api_base_url" {
  type = string
}

variable "node_env" {
  type = string
}

variable "dynamo_table_name" {
  type = string
}

variable "mercadopago_access_token" {
  type = string
}

variable "mercadopago_public_key" {
  type = string
}

variable "mercadopago_notification_url" {
  type = string
}

variable "mercadopago_success_url" {
  type = string
}

variable "mercadopago_failure_url" {
  type = string
}

variable "mercadopago_pending_url" {
  type = string
}