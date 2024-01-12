terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.environment == "development1" || var.environment == "production1" ? "eu-west-1" : "eu-central-1"
  profile = "default"
}