// This S3 bucket will hold artifacts for our knowledge base
resource "aws_s3_bucket" "knowledge_base_artifacts" {
  bucket = "boardgamebot-knowledge-base-bucket"
}

// Create a KMS key for encryption
resource "aws_kms_key" "knowledge_base_artifacts" {
  description = "KMS key for boardgamebot knowledge base bucket"
}

resource "aws_kms_alias" "knowledge_base_artifacts" {
  name          = "alias/managed/s3/boardgamebot-knowledge-base-bucket"
  target_key_id = aws_kms_key.knowledge_base_artifacts.id
}

// Attach the KMS key to the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "knowledge_base_artifacts" {
  bucket = aws_s3_bucket.knowledge_base_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_alias.knowledge_base_artifacts.id
    }
  }
}

resource "aws_s3_bucket_public_access_block" "knowledge_base_artifacts" {
  bucket = aws_s3_bucket.knowledge_base_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}