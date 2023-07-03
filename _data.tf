data "aws_iam_account_alias" "current" {
  count = var.alarm_prefix == "" ? 1 : 0
}

data "aws_s3_bucket" "selected" {
  for_each = { for i in var.dynamic_custom_origin_config : i.origin_id => i if i.s3 }
  bucket   = each.value.origin_id
}
