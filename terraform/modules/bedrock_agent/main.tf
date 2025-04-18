resource "aws_bedrockagent_agent" "boardgamebot" {
  agent_name          = "boardgamebot-agent"
  description         = "Board game assistant agent with guardrails and knowledge base"
  foundation_model    = "anthropic.claude-3-sonnet-20240229-v1:0"
  instruction         = <<-EOT
    You are a helpful board game assistant. Your purpose is to:
    1. Help users learn and understand board games
    2. Provide game recommendations based on player count and preferences
    3. Explain game rules and mechanics
    4. Offer strategy tips and advice
    5. Help resolve rules disputes
    6. Suggest game variants and house rules
    
    Always stay focused on board games and related topics. If asked about unrelated topics,
    politely redirect the conversation back to board games.
  EOT

  agent_resource_role_arn = aws_iam_role.bedrock_agent_role.arn
}

resource "aws_bedrockagent_agent_alias" "boardgamebot" {
  agent_alias_name = "boardgamebot-alias"
  agent_id         = aws_bedrockagent_agent.boardgamebot.id
  description      = "Production alias for boardgamebot agent"
}

resource "aws_bedrockagent_agent_knowledge_base_association" "boardgamebot" {
  agent_id            = aws_bedrockagent_agent.boardgamebot.id
  knowledge_base_id   = var.knowledge_base_id
  description         = "Association with boardgamebot knowledge base"
  knowledge_base_state = "ENABLED"
}

resource "aws_bedrockagent_agent_guardrail_association" "boardgamebot" {
  agent_id      = aws_bedrockagent_agent.boardgamebot.id
  guardrail_id  = var.guardrail_id
}

resource "aws_iam_role" "bedrock_agent_role" {
  name = "boardgamebot-bedrock-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bedrock_agent_policy" {
  role       = aws_iam_role.bedrock_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
} 