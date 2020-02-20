output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront Distribution."
  value       = aws_cloudfront_distribution.default.id
}

output "cloudfront_distribution_hostname" {
  description = "The hostname of the CloudFront Distribution (use for DNS CNAME)."
  value       = aws_cloudfront_distribution.default.domain_name
}

output "cloudfront_zone_id" {
  description = "The Zone ID of the CloudFront Distribution (use for DNS Alias)."
  value       = aws_cloudfront_distribution.default.hosted_zone_id
}
