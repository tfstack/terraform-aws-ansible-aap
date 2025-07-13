# Storage Module - S3 Bucket and Objects

# Random suffix for bucket name uniqueness
resource "random_id" "bucket_suffix" {
  count       = var.aap_package_mode == "upload" ? 1 : 0
  byte_length = 4
}

# S3 Bucket for AAP installer (conditionally created)
resource "aws_s3_bucket" "aap_installer" {
  count  = var.aap_package_mode == "upload" ? 1 : 0
  bucket = "${var.name}-aap-installer-${random_id.bucket_suffix[0].hex}"

  tags = var.tags
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "aap_installer" {
  count  = var.aap_package_mode == "upload" ? 1 : 0
  bucket = aws_s3_bucket.aap_installer[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "aap_installer" {
  count  = var.aap_package_mode == "upload" ? 1 : 0
  bucket = aws_s3_bucket.aap_installer[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "aap_installer" {
  count  = var.aap_package_mode == "upload" ? 1 : 0
  bucket = aws_s3_bucket.aap_installer[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload AAP installer to S3 (if in upload mode)
resource "aws_s3_object" "aap_installer" {
  count  = var.aap_package_mode == "upload" ? 1 : 0
  bucket = aws_s3_bucket.aap_installer[0].bucket
  key    = var.s3_object_key
  source = var.aap_installer_path

  server_side_encryption = "AES256"

  tags = var.tags
}
