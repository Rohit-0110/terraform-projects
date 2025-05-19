module my_application_ci {
  source = "./application-ci"

  application_name = "rohit"
  admin_users = [
    rohit # IAM usernames for admin users
  ]

  # Any policies here are added to both CI and Admin users
  # The policies below grant read access to most non-secret data
  view_policies = local.default_view_policies

  # These statements are added to the CI user and to the permission boundary that the CI user must assign to roles and policies
  # See data.aws_iam_policy_document.ci_delegated_permission_boundary for the other policy statements that are always included 
  # The policies below allow SSM access and advanced CloudWatch metrics
  delegated_permissions = local.default_instance_policies_json


  # (Optional) These statements are assigned to the CI user.
  # The defaults allow access to manage most resources based on the application name.
  ci_policy = data.aws_iam_policy_document.additional_ci_policy.json

}

data "aws_iam_policy_document" "additional_ci_policy" {
  statement {
    sid = "LabDNS"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = [
      # Only in the private zone
      data.aws_route53_zone.private_psi.arn,
    ]
    # Add lab subdomains
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
      values = [
        "*.lab.test.com",
        "*.hansen.test.com",
        "*.daresbury.test.com",
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
}

