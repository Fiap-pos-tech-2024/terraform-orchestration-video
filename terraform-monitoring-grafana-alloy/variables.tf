variable "grafana_remote_write_url" {
  description = "URL de remote_write do Grafana Cloud"
  type        = string
  sensitive   = true
}

variable "grafana_username" {
  description = "Username (API Key ID) do Grafana Cloud"
  type        = string
  sensitive   = true
}

variable "grafana_password" {
  description = "Senha (API Key Secret) do Grafana Cloud"
  type        = string
  sensitive   = true
}
