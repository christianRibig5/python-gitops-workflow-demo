data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_permissions" {
  statement {
    sid    = "DescribeEKSCluster"
    effect = "Allow"

    actions = [
      "eks:DescribeCluster"
    ]

    resources = [
      "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}"
    ]
  }
}

module "github_actions_oidc" {
  source = "./modules"

  github_owner = var.github_owner

  repositories = [
    var.github_repository
  ]

  branches = [
    "main"
  ]

  role_name            = var.github_role_name
  create_oidc_provider = var.create_oidc_provider
  inline_policy_json   = data.aws_iam_policy_document.github_permissions.json

  tags = {
    Project   = var.github_repository
    ManagedBy = "Terraform"
  }
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = var.eks_cluster_name
  principal_arn = module.github_actions_oidc.role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions" {
  cluster_name  = var.eks_cluster_name
  principal_arn = module.github_actions_oidc.role_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = [var.kubernetes_namespace]
  }

  depends_on = [
    aws_eks_access_entry.github_actions
  ]
}
