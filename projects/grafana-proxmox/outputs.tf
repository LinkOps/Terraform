output "grafana_url" {
  description = "Grafana web URL once provisioning is complete."
  value       = "http://${split("/", var.ip_cidr)[0]}:3000"
}

output "deployment_mode" {
  description = "Selected deployment mode."
  value       = var.deployment_mode
}
