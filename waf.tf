resource "aws_wafv2_web_acl" "waf_cloudfront" {
  count = var.waf_cloudfront_enable && var.cloudfront_web_acl_id == null ? 1 : 0
  name        = "waf-cloudfront-${var.name}"
  description = "WAF managed rules for Cloudfront"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  dynamic "rule" {


    for_each = local.wafv2_rules

    content {
      name     = "waf-${var.name}-${rule.value.type}-${rule.value.name}"
      priority = rule.key

      dynamic "override_action" {
        for_each = rule.value.type == "managed" ? [1] : []
        content {
          count {}
        }
      }

      dynamic "action" {
        for_each = rule.value.type == "rate" ? [1] : []
        content {
          block {}
        }
      }

      statement {
        dynamic "rate_based_statement" {
          for_each = rule.value.type == "rate" ? [1] : []
          content {
            limit              = rule.value.value
            aggregate_key_type = "IP"
          }
        }

        dynamic "managed_rule_group_statement" {
          for_each = rule.value.type == "managed" || rule.value.type == "managed_block" ? [1] : []
          content {
            name        = rule.value.name
            vendor_name = "AWS"
          }
        }
      }


      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "waf-${var.name}-${rule.value.type}-${rule.value.name}"
        sampled_requests_enabled   = false
      }
    }
  }

  tags = {
    Name = "waf-cloudfront-${var.name}-static-application"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-cloudfront-${var.name}-general"
    sampled_requests_enabled   = false
  }

}

locals {
  wafv2_managed_rule_groups       = [for i, v in var.wafv2_managed_rule_groups : { "name" : v, "type" : "managed" }]
  wafv2_managed_block_rule_groups = [for i, v in var.wafv2_managed_block_rule_groups : { "name" : v, "type" : "managed_block" }]
  wafv2_rate_limit_rule = var.wafv2_rate_limit_rule == 0 ? [] : [{
    "name" : "limit"
    "type" : "rate"
    "value" : var.wafv2_rate_limit_rule
  }]
  wafv2_rules = concat(local.wafv2_rate_limit_rule, local.wafv2_managed_block_rule_groups, local.wafv2_managed_rule_groups)
}
