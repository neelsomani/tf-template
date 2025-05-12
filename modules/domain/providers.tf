terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.85"
    }
  }
}

provider "aws" {
  alias  = "route53_domains_region"
  region = "us-east-1"
} 