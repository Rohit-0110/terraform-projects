terraform {
  backend "s3" {
    bucket = "my-terraform-state-abc"
    key    = "terraform-state-file"
    region = "us-east-1"
  }
}
