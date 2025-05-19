data "aws_iam_policy_document" "deployment_permissions" {
  statement {
    sid = "DeploymentBucketGlobal"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Describe*",
    ]
    resources = [
      "arn:aws:s3:::psi-deployments-storage",
      "arn:aws:s3:::psi-deployments-storage/*",
    ]
  }

  statement {
    sid = "DeploymentBucketForApplication"
    actions = [
      "s3:Delete*",
      "s3:Put*",
    ]
    resources = [
      "arn:aws:s3:::psi-deployments-storage/${lower(var.application_name)}/*",
    ]
  }
}
