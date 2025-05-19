locals {
  plm = {
    tags = {
      application = "plm"
      Team        = "m4"
    }
  }
}

# Certificate SSL
resource "aws_acm_certificate" "plm_cert" {
  domain_name       = "*.plm.test.com"        # replace with your domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# DNS record for ceritificate validate
resource "aws_route53_record" "plm_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.plm_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.psi_private.zone_id
}

# Certificate Validation
resource "aws_acm_certificate_validation" "plm_cert_validate" {
  certificate_arn         = aws_acm_certificate.plm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.plm_cert_validation : record.fqdn]
}

# DNS records
# Record 1
resource "aws_route53_record" "dev_client_dns" {
  zone_id = data.aws_route53_zone.psi_private.zone_id
  name    = "tc-dev.plm.test.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.dev_plm_lb.dns_name]
}

# Record 2
resource "aws_route53_record" "prod_client_dns" {
  zone_id = data.aws_route53_zone.psi_private.zone_id
  name    = "tc-prod.plm.test.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.prod_plm_lb.dns_name]
}