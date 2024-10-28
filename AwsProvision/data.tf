data "aws_instance" "cli_instance" {
  instance_id = "i-06901ca7e032e548f"
}

output "nontf_instance_ip" {
  value = data.aws_instance.cli_instance.public_ip
}
