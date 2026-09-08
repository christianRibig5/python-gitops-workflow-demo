output "github_actions_role_arn" {
  description = "IAM role ARN used by the GitHub Actions workflow."
  value       = module.github_actions_oidc.role_arn
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role."
  value       = module.github_actions_oidc.role_name
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider."
  value       = module.github_actions_oidc.oidc_provider_arn
}

output "github_allowed_subjects" {
  description = "GitHub repositories, branches, or environments allowed to assume the role."
  value       = module.github_actions_oidc.allowed_subjects
}
