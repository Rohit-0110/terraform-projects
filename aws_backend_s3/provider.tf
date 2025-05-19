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



# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "s3:ListBucket",
#       "Resource": "arn:aws:s3:::gitlab-psi-prod-m4-tcplm-terraform-state"
#     },
#     {
#       "Effect": "Allow",
#       "Action": ["s3:GetObject", "s3:PutObject"],
#       "Resource": [
#         "arn:aws:s3:::gitlab-psi-prod-m4-tcplm-terraform-state/*",
#         "arn:aws:s3:::gitlab-psi-prod-m4-tcplm-terraform-state/*.tflock"
#       ]
#     }
#   ]
# }
