terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Remote Backend
  backend "s3" {
    bucket       = "tfstate-dev-ca-central-1-i1zfl3al"
    key          = "kms/monitoring/dev/terraform.tfstate"
    region       = "ca-central-1" # Variables cannot be used in backend configuration
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.awscli_user_profile
}
