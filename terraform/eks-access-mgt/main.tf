resource "aws_eks_access_entry" "deployment_role" {
  cluster_name  = var.cluster_name
  principal_arn = var.deployment_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "deployment_role" {
  cluster_name  = var.cluster_name
  principal_arn = var.deployment_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = [var.deployment_namespace]
  }

  depends_on = [
    aws_eks_access_entry.deployment_role
  ]
}
