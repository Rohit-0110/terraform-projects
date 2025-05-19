resource "aws_s3_bucket" "remote_state" {
  bucket = "my-terraform-state-abc"

  tags = {
    Name = "terraform-backend"
  }
}

resource "aws_s3_bucket_ownership_controls" "remote_backend" {
  bucket = aws_s3_bucket.remote_state.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "remote_backend_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.remote_backend]

  bucket = aws_s3_bucket.remote_state.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "remote_backend_versioning" {
  bucket = aws_s3_bucket.remote_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_db_instance" "my_secret_db" {
  identifier           = "rds-db-instance"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = data.aws_secretsmanager_secret_version.secret_version.secret_string
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}