resource "aws_opensearchserverless_collection" "boardgamebot_knowledge_base" {
  name = "boardgamebot-knowledge-base"
  type = "VECTORSEARCH"
}

