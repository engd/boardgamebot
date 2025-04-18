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
