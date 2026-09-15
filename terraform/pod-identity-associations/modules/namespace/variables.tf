variable "namespace" {
  description = "Kubernetes namespace name"
  type        = string
}

variable "create_namespace" {
  description = "Whether Terraform should create the Kubernetes namespace"
  type        = bool
  default     = true
}
