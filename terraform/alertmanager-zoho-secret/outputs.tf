output "alertmanager_zoho_secret_arn" {
  description = "ARN of the Alertmanager Zoho SMTP secret"
  value       = aws_secretsmanager_secret.alertmanager_zoho_smtp.arn
}

output "alertmanager_zoho_secret_name" {
  description = "Name of the Alertmanager Zoho SMTP secret"
  value       = aws_secretsmanager_secret.alertmanager_zoho_smtp.name
}
