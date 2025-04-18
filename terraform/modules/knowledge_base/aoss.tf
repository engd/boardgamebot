data "aws_caller_identity" "this" {}

resource "aws_opensearchserverless_collection" "boardgamebot_knowledge_base" {
  name = "bgb-knowledge-base"
  type = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_access_policy.boardgamebot_kb_aoss_policy,
    aws_opensearchserverless_security_policy.boardgamebot_kb_encryption_policy,
    aws_opensearchserverless_security_policy.boardgamebot_kb_network_policy
  ]
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
            "index/*/*"
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
            "collection/*"
          ]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DescribeCollectionItems",
            "aoss:UpdateCollectionItems"
          ]
        }
      ]
      Principal = [
        aws_iam_role.boardgamebot_knowledge_base.arn,
        data.aws_caller_identity.this.arn
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
          "collection/*"
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
            "collection/*"
          ]
        },
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/*"
          ]
        }
      ]
      AllowFromPublic = true
    }
  ])
}
