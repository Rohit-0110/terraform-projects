# creating github repo
resource "github_repository" "terraform-infra-repo" {
  name        = "terraform-infra"
  description = "Infrastructure repository managed by Terraform"
  visibility  = "public"
  has_issues  = true
  has_wiki    = true
}

# output ssh clone url
output "repository_clone_url_ssh" {
  value = github_repository.terraform-infra-repo.ssh_clone_url
}

resource "aws_iam_role" "codepipeline_role" {
  name = "iam_role_for_codepipeline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# creating IAM policy
resource "aws_iam_role_policy" "codepipeline_policy" {

  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "codecommit:*",
          "codebuild:*",
          "elasticbeanstalk:*",
          "cloudformation:*",
          "autoscaling:*",
          "ec2:*",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}