data "aws_iam_policy_document" "ci_delegated_permission_boundary" {
  source_policy_documents = concat(
    [
      data.aws_iam_policy_document.deployment_permissions.json,
    ],
    var.delegated_permissions,
  )

  statement {
    sid = "AllowReadOnAll"
    actions = [
      "acm:List*",
      "acm:Describe*",
      "ec2:Describe*",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
      "ecr:GetAuthorizationToken",
      "timestream-influxdb:List*",
      "timestream-influxdb:Describe*",
      "autoscaling:Describe*",
      "ecs:List*",
      "ecs:Describe*",
    ]
    resources = ["*"]
  }

  statement {
    sid = "ManageResourcesByTagParent"
    actions = [
      "ec2:*",
      "ec2-instance-connect:*",
      "es:*",
      "autoscaling:*",
      "s3:*",
      "cloudformation:*",
      "rds:*",
      "elasticloadbalancing:*",
      "ssm:*",
      "elasticache:*",
      "sqs:*",
      "lambda:*",
      "ecr:*",
      "kms:*",
      "route53:*",
      "timestream:*",
      "logs:*",
      "cloudfront:*",
      "events:*",
      "wafv2:*",
      "elasticfilesystem:*",
      "iam:PutRolePolicy",
      "iam:PassRole",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:DeleteInstanceProfile",
      "application-autoscaling:*",
      "timestream-influxdb:*",
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
    sid = "ManageResourcesByArnParent"
    actions = [
      "iam:GetInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:UntagInstanceProfile",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:PassRole",
      "autoscaling:*",
      "s3:*",
      "rds:*",
      "elasticloadbalancing:*",
      "ssm:SendCommand",
      "elasticache:*",
      "iam:CreateServiceLinkedRole",
      "iam:CreatePolicy",
      "iam:TagPolicy",
      "iam:UntagPolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:ListEntitiesForPolicy",
      "iam:SetDefaultPolicyVersion",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:DeleteRole",
      "iam:PutRolePolicy",
      "ec2:ImportKeyPair",
      "logs:*",
      "sqs:*",
      "lambda:*",
      "ecr:*",
      "timestream:*",
      "dynamodb:*",
      "es:*",
      "kms:*",
      "secretsmanager:*",
      "events:*",
      "wafv2:*",
      "ecs:*",
    ]
    resources = [
      "arn:aws:iam::*:instance-profile/${lower(var.application_name)}*",
      "arn:aws:iam::*:instance-profile/${var.application_name}*",
      "arn:aws:iam::*:role/${lower(var.application_name)}*",
      "arn:aws:iam::*:role/${var.application_name}*",
      "arn:aws:autoscaling:*:*:launchConfiguration:*:launchConfigurationName/${lower(var.application_name)}*",
      "arn:aws:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/${lower(var.application_name)}*",
      "arn:aws:s3:::*${lower(var.application_name)}*/*",
      "arn:aws:s3:::*${lower(var.application_name)}*",
      "arn:aws:rds:*:*:cluster:${lower(var.application_name)}*",
      "arn:aws:rds:*:*:db:${lower(var.application_name)}*",
      "arn:aws:rds:*:*:subgrp:${lower(var.application_name)}*",
      "arn:aws:rds:*:*:pg:${lower(var.application_name)}*",
      "arn:aws:rds:*:*:snapshot:*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/${lower(var.application_name)}*",
      "arn:aws:elasticloadbalancing:*:*:listener/app/${lower(var.application_name)}*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/app/${lower(var.application_name)}*",
      "arn:aws:elasticloadbalancing:*:*:targetgroup/${lower(var.application_name)}*",
      "arn:aws:ssm:*::document/AWS-*",
      "arn:aws:elasticache:*:*:cluster:${lower(var.application_name)}*",
      "arn:aws:elasticache:*:*:replicationgroup:${lower(var.application_name)}*",
      "arn:aws:iam::*:policy/${lower(var.application_name)}*",
      "arn:aws:iam::*:role/${lower(var.application_name)}*",
      "arn:aws:ec2:*:*:key-pair/${lower(var.application_name)}*",
      "arn:aws:logs:*:*:log-group:/aws/*/${lower(var.application_name)}*:log-stream:*",
      "arn:aws:logs:*:*:log-group:/*${var.application_name}*",
      "arn:aws:sqs:*:*:${lower(var.application_name)}*",
      "arn:aws:ecr:*:*:repository/${lower(var.application_name)}*",
      "arn:aws:lambda:*:*:function:${lower(var.application_name)}*",
      "arn:aws:lambda:*:*:event-source-mapping:*",
      "arn:aws:timestream:*:*:${lower(var.application_name)}*",
      "arn:aws:dynamodb:*:*:table/${lower(var.application_name)}*",
      "arn:aws:es:*:*:domain/${lower(var.application_name)}*",
      "arn:aws:kms:*:*:alias/${lower(var.application_name)}/*",
      "arn:aws:secretsmanager:*:*:secret:${lower(var.application_name)}/*",
      "arn:aws:events:*:*:rule/${lower(var.application_name)}*",
      "arn:aws:wafv2:*:*:*/webacl/${lower(var.application_name)}*/*",
      "arn:aws:wafv2:*:*:*/ipset/${lower(var.application_name)}*/*",
      "arn:aws:wafv2:*:*:*/managedruleset/${lower(var.application_name)}*/*",
      "arn:aws:wafv2:*:*:*/rulegroup/${lower(var.application_name)}*/*",
      "arn:aws:wafv2:*:*:*/regexpatternset/${lower(var.application_name)}*/*",
      "arn:aws:ecs:*:*:cluster/${lower(var.application_name)}*",
      "arn:aws:ecs:*:*:service/${lower(var.application_name)}*/*",
      "arn:aws:ecs:*:*:task/${lower(var.application_name)}*/*",
      "arn:aws:ecs:*:*:task-definition/${lower(var.application_name)}*:*",
      "arn:aws:ecs:*:*:container-instance/${lower(var.application_name)}*/*",
      "arn:aws:iam::*:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService",
    ]
  }
}


# Any role that the CI user creates **must** include this policy as a permission boundary.
# The CI user can create/attach policies with any permissions or wildcards.
# The role will only actually have access to permissions in both places.
# This serves as a safety net so that one app cannot impact any others.
# Each app should still follow least-privilege for each policy it creates.
# https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html
resource "aws_iam_policy" "ci_delegated_permission_boundary" {
  name        = "${lower(var.application_name)}-ci-delegated-boundary"
  description = "Maximum permissions that ${var.application_name}-ci can delegate to policies, roles, and instance profiles"
  policy      = var.minify_delegated_policy ? jsonencode(jsondecode(data.aws_iam_policy_document.ci_delegated_permission_boundary.json)) : data.aws_iam_policy_document.ci_delegated_permission_boundary.json
}
