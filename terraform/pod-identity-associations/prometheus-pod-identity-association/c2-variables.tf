variable "aws_region" {
  description = "AWS Region for deployment"
  type        = string
  default     = "ca-central-1"
}

variable "awscli_user_profile" {
  description = "AWS CLI profile used to manage resources"
  type        = string
  default     = "dev-admin"
}

variable "environment_name" {
  description = "Environment used in resource names and tags"
  type        = string
  default     = "dev"
}

variable "prometheus_grafana_cloud_secret_name" {
  description = "Override the AWS Secrets Manager name of the Grafana Cloud token used by Prometheus"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to Prometheus Pod Identity resources"
  type        = map(string)

  default = {
    ManagedBy = "terraform"
    Owner     = "Christian Onyeukwu"
    Project   = "Python GitOps Workflow Demo"
    Service   = "prometheus"
    Purpose   = "Prometheus Grafana Cloud remote_write Pod Identity"
  }
}
