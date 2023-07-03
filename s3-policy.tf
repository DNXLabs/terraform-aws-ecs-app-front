data "aws_iam_policy_document" "s3_policy" {
  for_each = {for i in var.dynamic_custom_origin_config : i.origin_id => i if i.s3  }

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.selected[each.value.origin_id].arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default[each.value.origin_id].iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [data.aws_s3_bucket.selected[each.value.origin_id].arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default[each.value.origin_id].iam_arn]
    }
  }

  statement {
    sid     = "ForceSSLOnlyAccess"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [data.aws_s3_bucket.selected[each.value.origin_id].arn, "${data.aws_s3_bucket.selected[each.value.origin_id].arn}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [false]
    }
  }
}

resource "aws_s3_bucket_policy" "s3" {
  for_each = {for i in var.dynamic_custom_origin_config : i.origin_id => i if i.s3  }

  bucket = each.value.origin_id
  policy = data.aws_iam_policy_document.s3_policy[each.value.origin_id].json
}
