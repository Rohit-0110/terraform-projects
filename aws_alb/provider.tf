terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
  }

  backend "s3" {
    bucket = "gitlab-psi-prod-m4-tcplm-terraform-state"
    key    = "terraform/state"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}