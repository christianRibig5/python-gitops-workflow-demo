
resource "aws_eks_pod_identity_association" "app_pia" {
  for_each = var.pod_identities

  cluster_name    = var.cluster_name
  namespace       = each.value.namespace
  service_account = each.value.service_account_name
  role_arn        = aws_iam_role.pod_role[each.key].arn

  tags = merge(
    var.tags,
    {
      Namespace = each.value.namespace
      Service   = each.key
    }
  )

  depends_on = [
    kubernetes_service_account.app_sa,
    aws_iam_role_policy_attachment.pod_policy_attach
  ]
}
