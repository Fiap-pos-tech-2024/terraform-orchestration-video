variable "smtp_host" {
  description = "SMTP server hostname"
  type        = string
  default     = "smtp.gmail.com"
}

variable "smtp_port" {
  description = "SMTP server port"
  type        = number
  default     = 587
}

variable "smtp_user" {
  description = "SMTP username"
  type        = string
  sensitive   = true
}

variable "smtp_pass" {
  description = "SMTP password"
  type        = string
  sensitive   = true
}

variable "from_email" {
  description = "Email address to send notifications from"
  type        = string
}

variable "from_name" {
  description = "Name to display as sender"
  type        = string
  default     = "Video Processing System"
}
