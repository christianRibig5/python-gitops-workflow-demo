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

variable "github_owner" {
  description = "GitHub user or organization that owns the repository"
  type        = string
}

variable "github_repository" {
  description = "Repository containing the GitHub Actions workflow"
  type        = string
}

variable "github_role_name" {
  description = "Name of the IAM role assumed by GitHub Actions"
  type        = string
}

variable "create_oidc_provider" {
  description = "Whether Terraform should create the account-wide GitHub OIDC provider"
  type        = bool
  default     = true
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster deployed to by GitHub Actions"
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace managed by GitHub Actions"
  type        = string
  default     = "default"
}
