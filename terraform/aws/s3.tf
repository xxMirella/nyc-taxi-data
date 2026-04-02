resource "aws_s3_bucket" "taxi_data" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = "data-platform"
    Layer       = "bronze"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.bucket_name}-tf-state"
}

resource "aws_s3_bucket_ownership_controls" "taxi_data" {
  bucket = aws_s3_bucket.taxi_data.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "taxi_data" {
  bucket = aws_s3_bucket.taxi_data.id

  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "taxi_data" {
  bucket = aws_s3_bucket.taxi_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_public_access_block" "taxi_data" {
  bucket = aws_s3_bucket.taxi_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}