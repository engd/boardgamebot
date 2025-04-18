/* resource "aws_bedrockagent_knowledge_base" "boardgamebot" {
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
} */

/* resource "aws_bedrockagent_data_source" "boardgamebot" {
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
} */