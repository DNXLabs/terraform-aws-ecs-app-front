resource "aws_cloudfront_distribution" "default" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.hostname
  aliases             = concat(list(var.hostname), compact(split(",", var.hostname_redirects)))
  price_class         = "PriceClass_All"
  wait_for_deployment = false

  origin {
    domain_name = var.alb_dns_name
    origin_id   = "default"

    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["SSLv3", "TLSv1.1", "TLSv1.2", "TLSv1"]
    }

    custom_header {
      name  = "fromcloudfront"
      value = var.alb_cloudfront_key
    }
  }

  dynamic "logging_config" {
    for_each = compact([var.cloudfront_logging_bucket])

    content {
      include_cookies = false
      bucket          = var.cloudfront_logging_bucket
      prefix          = var.cloudfront_logging_prefix
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "default"
    compress         = true

    forwarded_values {
      query_string = true
      headers      = var.cloudfront_forward_headers

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = var.cloudfront_web_acl_id != "" ? var.cloudfront_web_acl_id : ""
}
