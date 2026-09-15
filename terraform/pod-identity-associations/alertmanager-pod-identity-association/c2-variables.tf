variable "aws_region" {
  description = "AWS Region for deployment"
  type        = string
  default     = "ca-central-1"
}

variable "awscli_user_profile" {
  description = "AWS CLI profile used to manage the resources"
  type        = string
  default     = "dev-admin"
}

variable "environment_name" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"
}

variable "zoho_secret_name" {
  description = "Name of the Zoho SMTP password in AWS Secrets Manager"
  type        = string
  default     = "dev/monitoring/alertmanager/zoho-smtp-password"
}

variable "tags" {
  description = "Tags applied to Alertmanager Pod Identity resources"
  type        = map(string)

  default = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "Christian Onyeukwu"
    Project     = "Python GitOps Workflow Demo"
    Service     = "alertmanager"
    Purpose     = "Alertmanager Zoho SMTP Pod Identity"
  }
}
