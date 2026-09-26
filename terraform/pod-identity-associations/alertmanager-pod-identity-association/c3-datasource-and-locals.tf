
data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "tfstate-dev-ca-central-1-i1zfl3al"
    key    = "eks/dev/terraform.tfstate"
    region = "ca-central-1"
  }
}

data "aws_eks_cluster_auth" "eks" {
  name = data.terraform_remote_state.eks.outputs.eks_cluster_name
}

data "aws_secretsmanager_secret" "alertmanager_zoho" {
  name = var.zoho_secret_name
}

provider "kubernetes" {
  host = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority_data
  )

  token = data.aws_eks_cluster_auth.eks.token
}
