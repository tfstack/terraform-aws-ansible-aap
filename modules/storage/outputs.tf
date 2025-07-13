# Storage Module Outputs

output "s3_bucket_name" {
  description = "Name of the S3 bucket containing AAP installer"
  value       = var.aap_package_mode == "upload" ? aws_s3_bucket.aap_installer[0].bucket : var.aap_installer_s3_bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket containing AAP installer"
  value       = var.aap_package_mode == "upload" ? aws_s3_bucket.aap_installer[0].arn : null
}

output "s3_object_key" {
  description = "S3 object key for the AAP installer"
  value       = var.aap_package_mode == "upload" ? var.s3_object_key : var.aap_installer_s3_key
}
