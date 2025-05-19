resource "aws_iam_group" "admins" {
  name = "${lower(var.application_name)}-admins"
}

data "aws_iam_policy_document" "admins" {
  source_policy_documents = [
    var.admin_policy,
    data.aws_iam_policy_document.deployment_permissions.json,
  ]

  statement {
    sid = "ViewNonMetadataParent"
    actions = [
      "secretsmanager:ListSecrets",
      "ssm:Describe*",
      "ssm:GetDocument*",
      "ssm:GetInventory",
      "ssm:GetInventory*",
      "ssm:GetMaintenanceWindow*",
      "ssm:GetManifest",
      "ssm:GetCommandInvocation",
      "ssm:List*",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "ManageAccessKeysForCDParent"
    actions = [
      "iam:GetUser",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
    ]
    resources = [
      aws_iam_user.ci_user.arn,
    ]
  }
  statement {
    sid = "ManageResourcesByTagParent"
    actions = [
      "ec2:*",
      "ec2-instance-connect:*",
      "ssm:*",
      "ssmmessages:*",
      "s3:*",
      "cloudformation:Get*",
      "cloudformation:Detect*",
      "rds:Get*",
      "rds:CreateDBSnapshot",
      "ecr:*",
      "elasticloadbalancing:*",
      "sqs:*",
      "lambda:*",
      "kms:*",
      "secretsmanager:*",
      "route53:*",
      "timestream:*",
      "dynamodb:*",
      "cloudfront:*",
      "iam:GetOpenIDConnectProvider",
      "ecs:*",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEqualsIgnoreCase"
      variable = "aws:ResourceTag/application"
      values = [
        var.application_name,
      ]
    }
  }
  statement {
    sid = "ManageYourOwnSSMSessions"
    actions = [
      "ssm:TerminateSession",
      "ssm:ResumeSession",
    ]
    resources = [
      "arn:aws:ssm:*:*:session/$${aws:username}-*",
    ]
  }
  statement {
    sid = "UnscopableBackups"
    actions = [
      "rds:StartExportTask",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    sid = "UnscopableEC2"
    actions = [
      "ec2:Create*",
      "ec2:Run*",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    sid = "ManageResourcesByArnParent"
    actions = [
      "autoscaling:*",
      "s3:*",
      "rds:Get*",
      "rds:Download*",
      "rds:CreateDBSnapshot",
      "ssm:SendCommand",
      "pi:*",
      "iam:PassRole",
      "secretsmanager:*",
    ]
    resources = [
      "arn:aws:autoscaling:*:*:launchConfiguration:*:launchConfigurationName/${lower(var.application_name)}*",
      "arn:aws:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/${lower(var.application_name)}*",
      "arn:aws:s3:::*${lower(var.application_name)}*/*",
      "arn:aws:s3:::*${lower(var.application_name)}*",
      "arn:aws:rds:*:*:cluster:${lower(var.application_name)}-*",
      "arn:aws:rds:*:*:db:${lower(var.application_name)}-*",
      "arn:aws:rds:*:*:snapshot:*",
      "arn:aws:ssm:*::document/AWS-*",
      "arn:aws:pi:*:*:metrics/rds/*",
      "arn:aws:iam::*:role/${lower(var.application_name)}*",
      "arn:aws:secretsmanager:*:*:secret:${var.application_name}/*",
      "arn:aws:secretsmanager:*:*:secret:${lower(var.application_name)}/*",
    ]
  }
  statement {
    sid = "AllowAdminsToRunAWSSupportDocuments"
    actions = [
      "ssm:StartAutomationExecution",
      "ssm:DescribeAutomationExecutions",
      "ssm:GetAutomationExecution",
      "ssm:DescribeAutomationStepExecutions",
      "ssm:StartAutomationExecution",
      "ssm:DescribeDocument",
      "ssm:GetDocument",
      "ssm:ListDocuments",
      "ssm:StartSession",
    ]
    resources = [
      "arn:aws:ssm:*::automation-definition/AWSSupport-Troubleshoot*",
      "arn:aws:ssm:*:*:document/SSM-*",
    ]
  }
}

resource "aws_iam_policy" "admins" {
  name        = "${lower(var.application_name)}-admins"
  description = "Permissions to enable administering ${lower(var.application_name)} infrastructure"
  policy      = data.aws_iam_policy_document.admins.json
}

resource "aws_iam_group_policy_attachment" "admins" {
  group      = aws_iam_group.admins.name
  policy_arn = aws_iam_policy.admins.arn
}

resource "aws_iam_group_policy_attachment" "admin_view_policies" {
  for_each   = toset(var.view_policies)
  group      = aws_iam_group.admins.name
  policy_arn = each.key
}

resource "aws_iam_group_membership" "admins" {
  group = aws_iam_group.admins.name
  name  = "${lower(var.application_name)}-admins-group-membership"
  users = var.admin_users
}
