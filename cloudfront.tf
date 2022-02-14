resource "aws_cloudfront_distribution" "default" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = join(", ", var.hostnames)
  aliases             = var.hostnames
  price_class         = "PriceClass_All"
  wait_for_deployment = false

  origin {
    domain_name = var.alb_dns_name
    origin_id   = "default"

    custom_origin_config {
      origin_protocol_policy   = "https-only"
      http_port                = 80
      https_port               = 443
      origin_ssl_protocols     = ["SSLv3", "TLSv1.1", "TLSv1.2", "TLSv1"]
      origin_keepalive_timeout = var.cloudfront_origin_keepalive_timeout
      origin_read_timeout      = var.cloudfront_origin_read_timeout
    }

    custom_header {
      name  = "fromcloudfront"
      value = var.alb_cloudfront_key
    }
  }

  dynamic "origin" {
    for_each = [for i in var.dynamic_custom_origin_config : {
      s3                       = lookup(i, "s3", false)
      domain_name              = i.domain_name
      origin_id                = i.origin_id != "" ? i.origin_id : "default"
      path                     = lookup(i, "origin_path", null)
      http_port                = i.http_port != "" ? i.http_port : 80
      https_port               = i.https_port != "" ? i.https_port : 443
      origin_protocol_policy   = i.origin_protocol_policy != "" ? i.origin_protocol_policy : "https-only"
      origin_read_timeout      = i.origin_read_timeout
      origin_keepalive_timeout = i.origin_keepalive_timeout
      origin_ssl_protocols     = lookup(i, "origin_ssl_protocols", ["SSLv3", "TLSv1.1", "TLSv1.2", "TLSv1"])
      custom_header            = lookup(i, "custom_header", null)
      origin_access_identity   = lookup(i, "origin_access_identity", "")
    }]

    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = origin.value.path

      dynamic "custom_header" {
        for_each = origin.value.custom_header == null ? [] : [for i in origin.value.custom_header : {
          name  = i.name
          value = i.value
        }]
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      custom_header {
        name  = "fromcloudfront"
        value = var.alb_cloudfront_key
      }

      dynamic "s3_origin_config" {
        for_each = origin.value.s3 == true ? [1] : []
        content {
          origin_access_identity = origin.value.origin_access_identity
        }
      }

      dynamic "custom_origin_config" {
        for_each = origin.value.s3 == true ? [] : [1]
        content {
          http_port                = origin.value.http_port
          https_port               = origin.value.https_port
          origin_keepalive_timeout = origin.value.origin_keepalive_timeout
          origin_read_timeout      = origin.value.origin_read_timeout
          origin_protocol_policy   = origin.value.origin_protocol_policy
          origin_ssl_protocols     = origin.value.origin_ssl_protocols
        }
      }

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
    allowed_methods  = var.default_cache_behavior_allowed_methods
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "default"
    compress         = try(var.default_cache_behavior_compress, false)

    origin_request_policy_id = var.default_cache_behavior_origin_request_policy_id
    cache_policy_id          = var.default_cache_behavior_cache_policy

    viewer_protocol_policy = "redirect-to-https"
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.dynamic_ordered_cache_behavior
    iterator = cache_behavior

    content {
      path_pattern     = cache_behavior.value.path_pattern
      allowed_methods  = cache_behavior.value.allowed_methods
      cached_methods   = cache_behavior.value.cached_methods
      target_origin_id = cache_behavior.value.target_origin_id
      compress         = try(cache_behavior.value.compress, false)

      dynamic "lambda_function_association" {
        iterator = lambda
        for_each = lookup(cache_behavior.value, "lambda_function_association", [])
        content {
          event_type   = lambda.value.event_type
          lambda_arn   = lambda.value.lambda_arn
          include_body = lookup(lambda.value, "include_body", null)
        }
      }

      origin_request_policy_id = cache_behavior.value.request_policy_id
      cache_policy_id          = cache_behavior.value.cache_policy

      viewer_protocol_policy = cache_behavior.value.viewer_protocol_policy
      min_ttl                = lookup(cache_behavior.value, "min_ttl", null)
      default_ttl            = lookup(cache_behavior.value, "default_ttl", null)
      max_ttl                = lookup(cache_behavior.value, "max_ttl", null)
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.certificate_arn
    iam_certificate_id             = var.iam_certificate_id
    cloudfront_default_certificate = var.certificate_arn == null && var.iam_certificate_id == null ? true : false
    ssl_support_method             = var.certificate_arn == null && var.iam_certificate_id == null ? null : "sni-only"
    minimum_protocol_version       = var.certificate_arn == null && var.iam_certificate_id == null ? "TLSv1.2_2018" : var.minimum_protocol_version
  }

  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
      locations        = var.restriction_location
    }
  }

  web_acl_id = var.cloudfront_web_acl_id != "" ? var.cloudfront_web_acl_id : ""
}
