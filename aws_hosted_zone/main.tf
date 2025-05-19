data "aws_route53_zone" "selected" {
  arn          = []
  name         = "test.com"
  private_zone = true
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.selected.zone_id
}