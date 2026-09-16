variable "aws_region" {
  description = "AWS Region for deployment"
  type        = string
  default     = "ca-central-1"
}

variable "awscli_user_profile" {
  description = "AWS CLI profile used to create the resources"
  type        = string
  default     = "dev-admin"
}

variable "environment_name" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"
}

variable "recovery_window_in_days" {
  description = "Days before AWS permanently deletes the secret"
  type        = number
  default     = 0

  validation {
    condition = (
      var.recovery_window_in_days == 0 ||
      (
        var.recovery_window_in_days >= 7 &&
        var.recovery_window_in_days <= 30
      )
    )
    error_message = "Use 0 for deletion without recovery, or a value between 7 and 30."
  }
}

variable "tags" {
  description = "Additional tags applied to the Secrets Manager secret"
  type        = map(string)

  default = {
    ManagedBy = "terraform"
    Owner     = "Christian Onyeukwu"
    Project   = "Python GitOps Workflow Demo"
    Service   = "grafana-admin"
  }
}
