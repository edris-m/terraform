terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
  required_providers {
   aws = {
    source = "hashicorp/aws"
  }
 }
 required_version = ">= 1.0"
}

