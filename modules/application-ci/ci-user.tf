resource "aws_iam_user" "ci_user" {
  name = "${lower(var.application_name)}-ci"
}

data "aws_route53_zone" "private_psi" {
  name         = "test.com"
  private_zone = true
}

data "aws_route53_zone" "private_psi_lan" {
  name         = "test.lan"
  private_zone = true
}

data "aws_acm_certificate" "test_wildcard_cert" {
  domain      = "test.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_iam_policy_document" "ci_user" {
  source_policy_documents = [
    var.ci_policy,
  ]

  statement {
    sid = "DelegatePermissions"
    actions = [
      "iam:CreateRole",
      "iam:PutRolePermissionsBoundary",
      "iam:AttachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
    ]
    resources = [
      "arn:aws:iam::*:role/${lower(var.application_name)}*",
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PermissionsBoundary"
      values = [
        aws_iam_policy.ci_delegated_permission_boundary.arn
      ]
    }
  }

  statement {
    sid = "LimitedDNS"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = [
      # Only in the private zone
      data.aws_route53_zone.private_psi.arn,
      data.aws_route53_zone.private_psi_lan.arn,
    ]
    # Only for the application's subdomain
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
      values = [
        "*.${var.application_name}.test.com",
        "*-${var.application_name}.test.com",
        "${var.application_name}.test.com",
        "*.${var.application_name}.test.lan",
        "*-${var.application_name}.test.lan",
        "${var.application_name}.test.lan",
      ]
    }
    # Only for Record Types that Web Applications use (for example, no email servers)
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
      values = [
        "A",
        "AAAA",
        "CNAME",
        "TXT",
      ]
    }
  }

  statement {
    sid = "CreateScopedResourcesParent"
    actions = [
      "ec2:Create*",
      "ec2:Add*",
      "autoscaling:*",
      "iam:TagInstanceProfile",
      "iam:CreateInstanceProfile",
      "s3:Create*",
      "rds:Create*",
      "elasticloadbalancing:Create*",
      "elasticache:Create*",
      "elasticache:AddTagsToResource*",
      "ssm:Put*",
      "iam:TagPolicy",
      "iam:UntagPolicy",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:ListEntitiesForPolicy",
      "iam:SetDefaultPolicyVersion",
      "iam:TagRole",
      "iam:UntagRole",
      "cloudfront:*",
      "elasticfilesystem:Create*",
      "elasticfilesystem:TagResource",
      "timestream-influxdb:Create*",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEqualsIgnoreCase"
      variable = "aws:RequestTag/application"
      values = [
        var.application_name,
      ]
    }
  }

  statement {
    sid = "UnscopableResourcesParent"
    actions = [
      "ec2:Create*",
      "ec2:Run*",
      "ec2:ModifyVolume",
      "ec2:ModifyNetworkInterfaceAttribute",
      "autoscaling:Create*",
      "iam:CreateInstanceProfile",
      "iam:GetInstanceProfile",
      "cloudformation:Create*",
      "ssm:GetDocument*",
      "ssm:GetInventory",
      "ssm:GetInventory*",
      "ssm:GetMaintenanceWindow*",
      "ssm:GetManifest",
      "ssm:GetCommandInvocation",
      "elasticache:CreateReplicationGroup",
      "ecr:GetAuthorizationToken",
      "lambda:CreateEventSourceMapping",
      "rds:StartExportTask",
      "route53:ChangeTagsForResource",
      "cloudfront:GetAccessRequestPolicy*",
      "cloudfront:GetOriginRequestPolicy*",
      "cloudfront:GetResponseHeadersPolicy*",
      "elasticfilesystem:DescribeMountTargets",
      "ecs:DeregisterTaskDefinition",
      "application-autoscaling:Describe*",
      "application-autoscaling:RegisterScalableTarget",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ci_user" {
  name        = "${lower(var.application_name)}-ci"
  description = "Permissions to manage infrastructure for ${var.application_name}"
  policy      = data.aws_iam_policy_document.ci_user.json
}

resource "aws_iam_user_policy_attachment" "ci_policies" {
  user       = aws_iam_user.ci_user.name
  policy_arn = aws_iam_policy.ci_user.arn
}

resource "aws_iam_user_policy_attachment" "ci_delegated_permission_boundary" {
  user       = aws_iam_user.ci_user.name
  policy_arn = aws_iam_policy.ci_delegated_permission_boundary.arn
}

resource "aws_iam_user_policy_attachment" "ci_view_policies" {
  for_each   = toset(var.view_policies)
  user       = aws_iam_user.ci_user.name
  policy_arn = each.key
}
