# ============================================================
# IAM roles for EKS Pod Identity
# ============================================================

resource "aws_iam_role" "pod_role" {
  for_each = var.pod_identities

  name = "${var.cluster_name}-${each.value.service_account_name}-role"

  assume_role_policy = var.trust_policy_json

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-${each.value.service_account_name}-role"
      Namespace   = each.value.namespace
      Service     = each.key
      Environment = var.environment_name
    }
  )
}

# ============================================================
# Optional IAM policy created inside this module
#
# This resource is created only when permission_policy_json
# is supplied. Its for_each no longer depends on an ARN that
# is unknown during Terraform planning.
# ============================================================

resource "aws_iam_policy" "pod_policy" {
  for_each = var.permission_policy_json != null ? var.pod_identities : {}

  name = "${var.cluster_name}-${each.value.service_account_name}-policy"

  description = "IAM permissions policy for ${each.value.namespace}/${each.value.service_account_name}"

  policy = var.permission_policy_json

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-${each.value.service_account_name}-policy"
      Namespace   = each.value.namespace
      Service     = each.key
      Environment = var.environment_name
    }
  )
}

# ============================================================
# Attach either:
# 1. A policy created inside this module, or
# 2. An existing policy supplied through managed_policy_arn
# ============================================================

resource "aws_iam_role_policy_attachment" "pod_policy_attach" {
  for_each = var.pod_identities

  role = aws_iam_role.pod_role[each.key].name

  policy_arn = (
    var.permission_policy_json != null
    ? aws_iam_policy.pod_policy[each.key].arn
    : var.managed_policy_arn
  )

  lifecycle {
    precondition {
      condition = (
        var.permission_policy_json != null ||
        var.managed_policy_arn != null
      )

      error_message = "Provide either permission_policy_json or managed_policy_arn."
    }
  }
}
