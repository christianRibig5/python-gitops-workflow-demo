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

variable "grafana_secret_name" {
  description = "Override the AWS Secrets Manager name of the Grafana admin password"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to Grafana Pod Identity resources"
  type        = map(string)

  default = {
    ManagedBy = "terraform"
    Owner     = "Christian Onyeukwu"
    Project   = "Python GitOps Workflow Demo"
    Service   = "grafana"
    Purpose   = "Grafana admin password Pod Identity"
  }
}
