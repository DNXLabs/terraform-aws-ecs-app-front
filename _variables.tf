variable "name" {
  description = "Name of your ECS service"
}

variable "cluster_name" {
  description = "Name of existing ECS Cluster to deploy this app to"
}

variable "hostname" {
  description = "Hostname to create DNS record for this app"
}

variable "hostname_blue" {
  description = "Blue hostname for testing the app"
}

variable "hostname_create" {
  description = "Create hostname in the hosted zone passed?"
  default     = true
}

variable "hosted_zone" {
  description = "Existing Hosted Zone domain to add hostnames as DNS records"
}

variable "hostname_redirects" {
  description = "List of hostnames to redirect to the main one, comma-separated"
  default     = ""
}

variable "alb_cloudfront_key" {
  description = "Key generated by terraform-aws-ecs module to allow ALB connection from CloudFront"
}

variable "alb_dns_name" {
  description = "ALB DNS Name that CloudFront will point as origin"
}

variable "certificate_arn" {
  description = "Certificate for this app to use in CloudFront (US), must cover `hostname` and (ideally) `hostname_blue` passed."
}

variable "cloudfront_web_acl_id" {
  default     = ""
  description = "Optional web acl (WAF) to attach to CloudFront"
}

variable "cloudfront_forward_headers" {
  default     = ["*"]
  description = "Headers to forward to origin from CloudFront"
}

variable "cloudfront_logging_bucket" {
  type        = string
  default     = null
  description = "Bucket to store logs from app"
}

variable "cloudfront_logging_prefix" {
  type        = string
  default     = ""
  description = "Logging prefix"
}

variable "alarm_cloudfront_500_errors_threshold" {
  default     = 5
  description = "Cloudfront 500 Errors rate threshold (use 0 to disable this alarm)"
}

variable "alarm_sns_topics_us" {
  default     = []
  description = "Alarm topics to create and alert on metrics on US region"
}
