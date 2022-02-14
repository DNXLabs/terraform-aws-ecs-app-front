resource "aws_cloudwatch_metric_alarm" "cloudfront_500_errors" {
  provider = aws.us-east-1
  count    = length(var.alarm_sns_topics_us) > 0 && var.alarm_cloudfront_500_errors_threshold != 0 ? 1 : 0

  alarm_name                = "${try(data.aws_iam_account_alias.current[0].account_alias, var.alarm_prefix)}-ecs-${var.name}-cloudfront-500-errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "3"
  metric_name               = "5xxErrorRate"
  namespace                 = "AWS/CloudFront"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = var.alarm_cloudfront_500_errors_threshold
  alarm_description         = "Cloudfront errors above threshold"
  alarm_actions             = var.alarm_sns_topics_us
  ok_actions                = var.alarm_sns_topics_us
  insufficient_data_actions = []
  treat_missing_data        = "ignore"

  dimensions = {
    Region         = "Global"
    DistributionId = aws_cloudfront_distribution.default.id
  }
}
