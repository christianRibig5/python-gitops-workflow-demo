
variable "pod_identities" {
  description = "Map of Kubernetes service accounts requiring EKS Pod Identity"

  type = map(object({
    namespace            = string
    service_account_name = string
  }))
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment_name" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "trust_policy_json" {
  description = "IAM trust policy JSON for the Pod Identity role"
  type        = string
}

variable "permission_policy_json" {
  description = "Custom IAM permissions policy JSON created inside this module"
  type        = string
  default     = null
}

variable "managed_policy_arn" {
  description = "Existing AWS-managed or customer-managed IAM policy ARN attached to the Pod Identity role"
  type        = string
  default     = null
}

variable "tags" {
  description = "Global tags applied to AWS resources"
  type        = map(string)
  default     = {}
}

variable "create_service_account" {
  description = "Whether Terraform should create the Kubernetes service accounts"
  type        = bool
  default     = true
}

variable "create_namespace" {
  description = "Whether Terraform should create application namespaces"
  type        = bool
  default     = true
}
