variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "awscli_user_profile" {
  description = "AWS CLI profile used by Terraform"
  type        = string
}

variable "environment_name" {
  description = "Deployment environment name"
  type        = string
}

variable "tags" {
  description = "Common tags applied to resources"
  type        = map(string)
  default     = {}
}
