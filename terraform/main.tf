terraform {
  cloud {
    hostname = "app.terraform.io"

    workspaces {
      name = "boardgamebot"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.85.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Creating a VPC for the demo using a community-maintained VPC module
# Using 2 Availability Zones with public and private subnets in each
# A NAT Gateway will be deployed to enable internet access from private subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = "bedrock-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "knowledge_base" {
  source = "./modules/knowledge_base"
}

resource "aws_bedrockagent_agent" "boardgamebot" {
  agent_name       = "boardgamebot-agent"
  description      = "Board game assistant agent with guardrails and knowledge base"
  foundation_model = "anthropic.claude-3-5-sonnet-20240620-v1:0"
  instruction      = <<-EOT
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
  guardrail_configuration = [
    {
      guardrail_identifier = aws_bedrock_guardrail.boardgamebot.guardrail_id
      guardrail_version    = aws_bedrock_guardrail_version.boardgamebot.version
    }
  ]
}

resource "aws_bedrockagent_agent_alias" "boardgamebot" {
  agent_alias_name = "boardgamebot-alias"
  agent_id         = aws_bedrockagent_agent.boardgamebot.id
  description      = "Production alias for boardgamebot agent"
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