data "aws_route53_zone" "selected" {
  name = var.hosted_zone
}

resource "aws_route53_record" "hostname" {
  count = var.hostname_create ? 1 : 0

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.hostname
  type    = "CNAME"
  ttl     = "300"
  records = list(element(aws_cloudfront_distribution.default.*.domain_name, 0))
}

