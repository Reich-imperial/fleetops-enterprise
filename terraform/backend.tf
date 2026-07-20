terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-samson-2tier"
    key    = "fleetops-enterprise/terraform.tfstate"
    region = "us-east-1"
    # Add dynamodb_table for state locking once created — noted as a follow-up,
    # not a blocker for Phase 1.
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "fleetops-enterprise"
      ManagedBy = "terraform"
    }
  }
}
