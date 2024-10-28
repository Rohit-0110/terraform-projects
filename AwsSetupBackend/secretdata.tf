data "aws_secretsmanager_secret" "database_password" {
  name = "my-database-password"
}

data "aws_secretsmanager_secret_version" "secret_version" {
  secret_id = data.aws_secretsmanager_secret.database_password.id
}
