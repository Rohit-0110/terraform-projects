resource "aws_db_subnet_group" "app_db_subnet_group" {
  name       = "app-db-subnet-group"
  subnet_ids = [aws_subnet.AppSubnet1.id, aws_subnet.AppSubnet2.id]

  tags = {
    Name = "app-db-subnet-group"
  }
}

# create secret using below command
# aws secretsmanager create-secret --name app_db --secret-string "db*pass123"

data "aws_secretsmanager_secret" "app_db" {
  name = "app_db"
}

data "aws_secretsmanager_secret_version" "secret_app_db" {
  secret_id = data.aws_secretsmanager_secret.app_db.id
}

resource "aws_db_instance" "app_database" {
  identifier             = "appdatabase"
  allocated_storage      = 20
  db_name                = "appdatabase"
  engine                 = "mysql"
  engine_version         = "8.0.33"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = data.aws_secretsmanager_secret_version.secret_app_db.secret_string
  vpc_security_group_ids = [aws_security_group.WebTrafficSG.id]
  db_subnet_group_name   = aws_db_subnet_group.app_db_subnet_group.name
  publicly_accessible    = true

  tags = {
    Name = "AppDatabase"
  }
}