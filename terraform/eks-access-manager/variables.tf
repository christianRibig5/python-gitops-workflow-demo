variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ca-central-1"
}

variable "awscli_user_profile" {
  description = "AWS CLI profile used to run Terraform"
  type        = string
  default     = "dev-admin"
}

variable "cluster_name" {
  type = string
}

variable "deployment_role_arn" {
  type = string
}

variable "deployment_namespace" {
  type    = string
  default = "default"
}
