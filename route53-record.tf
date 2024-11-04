data "aws_route53_zone" "selected" {
  name = var.hosted_zone
}

resource "aws_route53_record" "hostname" {
  count = var.hostname_create ? length(var.hostnames) : 0

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.hostnames[count.index]
  type    = var.record_type
  ttl     = "300"
  records = [element(aws_cloudfront_distribution.default.*.domain_name, 0)]
}
