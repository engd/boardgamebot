terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.69"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "= 2.3.1"
    }
  }
}

provider "opensearch" {
  url         = aws_opensearchserverless_collection.boardgamebot_knowledge_base.collection_endpoint
  healthcheck = false
}


resource "aws_opensearchserverless_collection" "boardgamebot_knowledge_base" {
  name = var.collection_name
  type = "VECTORSEARCH"
  description = "OpenSearch Serverless collection for boardgamebot knowledge base"

  depends_on = [
    aws_opensearchserverless_access_policy.boardgamebot_kb_aoss_policy,
    aws_opensearchserverless_security_policy.boardgamebot_kb_encryption_policy,
    aws_opensearchserverless_security_policy.boardgamebot_kb_network_policy
  ]
}

/* resource "opensearch_index" "bgb_knowledge_base_index" {
  name                           = "bedrock-knowledge-base-default-index"
  number_of_shards               = "2"
  number_of_replicas             = "1"
  index_knn                      = true
  index_knn_algo_param_ef_search = "512"
  mappings                       = <<-EOF
    {
      "properties": {
        "bedrock-knowledge-base-default-vector": {
          "type": "knn_vector",
          "dimension": "1024",
          "method": {
            "name": "hnsw",
            "engine": "FAISS",
            "parameters": {
              "m": 16,
              "ef_construction": 512
            },
            "space_type": "l2"
          }
        },
        "AMAZON_BEDROCK_METADATA": {
          "type": "text",
          "index": "false"
        },
        "AMAZON_BEDROCK_TEXT_CHUNK": {
          "type": "text",
          "index": "true"
        }
      }
    }
  EOF
  lifecycle {
    ignore_changes = all
  }
  force_destroy = true
  depends_on    = [aws_opensearchserverless_collection.boardgamebot_knowledge_base]
}  */