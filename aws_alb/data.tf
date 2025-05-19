# hosted zone
data "aws_route53_zone" "psi_private" {
  name         = "test.com"                 #replace with your domain
  private_zone = true
}

# prod instance
data "aws_instance" "siemens_prod" {
  instance_id = var.siemens_prod_inst
}

# dev instance
data "aws_instance" "siemens_dev" {
  instance_id = var.siemens_dev_inst
}

# vpc 
data "aws_vpc" "psi_vpc" {
  id = var.vpc
}