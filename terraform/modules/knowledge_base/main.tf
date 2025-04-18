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

resource "aws_s3_bucket_lifecycle_configuration" "knowledge_base_artifacts" {
  bucket = aws_s3_bucket.knowledge_base_artifacts.id

  rule {
    id     = "ABORT_INCOMPLETE_UPLOADS"
    status = "Enabled"
    abort_incomplete_multipart_upload { days_after_initiation = 1 }
  }
}


resource "aws_bedrockagent_knowledge_base" "boardgamebot" {
  name     = "boardgamebot-knowledge-base"
  role_arn = aws_iam_role.boardgamebot_knowledge_base.arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:eu-central-1::foundation-model/amazon.titan-embed-text-v2:0"
    }
    type = "VECTOR"
  }
  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.boardgamebot_knowledge_base.arn
      vector_index_name = "bedrock-knowledge-base-default-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }
}

resource "aws_bedrockagent_data_source" "boardgamebot" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.boardgamebot.id
  name              = "bedrock-knowledge-base-data-source-bucket"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.knowledge_base_artifacts.arn
    }
  }
  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "SEMANTIC"
      semantic_chunking_configuration {
        breakpoint_percentile_threshold = 50
        buffer_size                     = 1
        max_token                       = 1000
      }
    }
  }
}

resource "aws_iam_role" "boardgamebot_knowledge_base" {
  name               = "bedrock-kb-role"
  assume_role_policy = data.aws_iam_policy_document.boardgamebot_knowledge_base_assume_role.json
}

data "aws_iam_policy_document" "boardgamebot_knowledge_base_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
  }
}

