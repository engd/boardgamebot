resource "aws_opensearchserverless_collection" "boardgamebot_knowledge_base" {
  name = "bgb-knowledge-base"
  type = "VECTORSEARCH"
}

resource "aws_opensearchserverless_access_policy" "boardgamebot_kb_aoss_policy" {
  name = "bgb-kb-aoss-access-policy"
  type = "data"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index"
          Resource = [
            "index/${aws_opensearchserverless_collection.boardgamebot_knowledge_base.name}/*"
          ]
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:UpdateIndex",
            "aoss:WriteDocument"
          ]
        },
        {
          ResourceType = "collection"
          Resource = [
            "collection/${aws_opensearchserverless_collection.boardgamebot_knowledge_base.name}"
          ]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DescribeCollectionItems",
            "aoss:UpdateCollectionItems"
          ]
        }
      ]
    }
  ])
}

resource "aws_opensearchserverless_security_policy" "boardgamebot_kb_encryption_policy" {
  name = "bgb-kb-aoss-encryption-policy"
  type = "encryption"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${aws_opensearchserverless_collection.boardgamebot_knowledge_base.name}"
        ]
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_security_policy" "boardgamebot_kb_network_policy" {
  name = "bgb-kb-aoss-network-policy"
  type = "network"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource = [
            "collection/${aws_opensearchserverless_collection.boardgamebot_knowledge_base.name}"
          ]
        },
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${aws_opensearchserverless_collection.boardgamebot_knowledge_base.name}"
          ]
        }
      ]
      AllowFromPublic = true
    }
  ])
}
