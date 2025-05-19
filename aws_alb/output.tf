output "vpc_id" {
  value = data.aws_vpc.psi_vpc.id
}

output "Dev_instance" {
  value = data.aws_instance.siemens_dev.id
}

output "Prod_instance" {
  value = data.aws_instance.siemens_prod.id
}

output "dev_lb_dns" {
  value = aws_lb.dev_plm_lb.dns_name
}

output "prod_lb_dns" {
  value = aws_lb.prod_plm_lb.dns_name
}
