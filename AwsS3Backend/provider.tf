provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-7c63958e6cea"
    key            = "terraform/state"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}


# to check using aws command
# aws s3 ls s3://my-terraform-state-bucket-7c63958e6cea/terraform/state