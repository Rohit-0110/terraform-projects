provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      repo        = "https://gitlab.test.com/DevOps_Infrastructure/aws-core-infrastructure"
      application = var.application_name
      owner       = element(var.admin_users, 0)
    }
  }
}
