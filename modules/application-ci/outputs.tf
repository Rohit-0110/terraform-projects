output "ci_user" {
  value = {
    arn       = aws_iam_user.ci_user.arn
    user_name = aws_iam_user.ci_user.name
  }
}

data "aws_iam_user" "admin_users" {
  for_each  = toset(var.admin_users)
  user_name = each.key
}

output "admin_users" {
  value = [
    for index, user in data.aws_iam_user.admin_users : {
      arn       = user.arn
      user_name = user.user_name
    }
  ]
}
