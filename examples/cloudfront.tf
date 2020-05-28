module "ecs_app_api_front" {
  source = "git::https://github.com/DNXLabs/terraform-aws-ecs-app-front.git?ref=1.8.0"

  providers = {
    aws.us-east-1 = aws.us-east-1
  }

  name                = "Client Name"
  cluster_name        = "nonprod"
  hostname            = "test.dnx.solutions"
  hosted_zone         = "dnx.solutions"
  hostname_create     = true
  hostname_redirects  = var.hostname_redirects
  alb_cloudfront_key  = random_string.alb_cloudfront_key.result #data.aws_ssm_parameter.alb_cloudfront_key.value
  certificate_arn     = data.aws_acm_certificate.domain_host_us.arn
  alb_dns_name        = aws_lb.ecs.dns_name
  alarm_sns_topics_us = var.alarm_sns_topics_us
  dynamic_custom_origin_config = [
    {
      domain_name              = "test.dnx.solutions"
      origin_id                = "test-origin.dnx.solutions"
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2", "TLSv1.1"]
      custom_header = [
        {
          name  = "Test1"
          value = "Test1-Header"
        },
        {
          name  = "Test2"
          value = "Test2-Header"
        }
      ]
    },
    {
      domain_name              = "test-2.dnx.solutions"
      origin_id                = "test-2-origin.dnx.solutions"
      origin_path              = ""
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2", "TLSv1.1"]
    }
  ]
  dynamic_ordered_cache_behavior = [{
    path_pattern           = "path/test*",
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"],
    cached_methods         = ["GET", "HEAD"],
    target_origin_id       = "test-2-origin.dnx.solutions",
    compress               = false,
    query_string           = true,
    cookies_forward        = "all",
    headers                = ["Accept", "Authorization", "Origin"],
    viewer_protocol_policy = "redirect-to-https",
    min_ttl                = 0,
    default_ttl            = 0,
    max_ttl                = 0,
    lambda_function_association = [{
      event_type   = "origin-request",
      lambda_arn   = "arn:aws:lambda:us-east-1:xxxxxxxxx:function:test-lambda-edge:1",
      include_body = false
    }]
  }]
}
