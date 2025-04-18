resource "aws_bedrock_guardrail" "boardgamebot" {
  name        = "bgb-guardrail"
  description = "Guardrail for boardgamebot Bedrock application"

  blocked_input_messaging   = "I'm sorry, I can't help with that request."
  blocked_outputs_messaging = "I'm sorry, I can't provide that information."

  content_policy_config {
    filters_config {
      type            = "HATE"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
  }

  word_policy_config {
    managed_word_lists_config {
      type = "PROFANITY"
    }
  }

  topic_policy_config {
    topics_config {
      name       = "Gambling"
      examples   = ["How much should I bet on games of Catan?"]
      definition = "Any discussion about gambling, betting, or games of chance"
      type       = "DENY"
    }
  }

  contextual_grounding_policy_config {
    filters_config {
      type      = "RELEVANCE"
      threshold = 70
    }
  }
}
