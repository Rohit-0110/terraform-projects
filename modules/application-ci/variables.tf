variable "application_name" {
  type        = string
  description = "The name of the application will be used for Tags and resource names."
}

variable "admin_users" {
  type        = list(string)
  description = "IAM usernames for application admins."
}

variable "view_policies" {
  type        = list(string)
  description = "ARNs for the policies defining view-only access given to admins and the CI user."
}

variable "admin_policy" {
  type        = string
  description = "JSON for the additional policy statements to assign to admins. The module includes access to the CI user, SSM on tagged instances, and access to Secrets Manager secrets starting with the application name."
  default     = "{}"
}

variable "ci_policy" {
  type        = string
  description = "JSON for the policy statements to assign to the CI user. The module includes EC2, Autoscaling, and IAM access on resources tagged with the application name or that start with the application name when tags dont' work."
  default     = "{}"
}

variable "delegated_permissions" {
  type        = list(string)
  description = "JSON for the policy statements to assign allow the CI user to add to delegated roles and policies. The module includes EC2, Autoscaling, and IAM access on resources tagged with the application name."
  default     = []
}

variable "minify_delegated_policy" {
  type        = bool
  description = "The delegated policy is quite large by default. When passing additional delegated policies, set this to `true` to minify the resulting policy as a workaround for the AWS max policy limit of 6144 characters."
  default     = false
}

data "aws_caller_identity" "current" {
}

locals {
  region     = "us-west-2"
  account_id = data.aws_caller_identity.current.account_id
}
