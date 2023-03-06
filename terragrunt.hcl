remote_state {
  backend = "s3"
  # config is an attribute, so an equals sign is REQUIRED
  config = {
    bucket         = "edris-tf-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "edris-terraform-lock"

    # s3_bucket_tags is an attribute, so an equals sign is REQUIRED
    s3_bucket_tags = {
      owner = "terragrunt"
      name = "Terraform state storage"
    }

    # dynamodb_table_tags is an attribute, so an equals sign is REQUIRED
    dynamodb_table_tags = {
      owner = "terragrunt"
      name = "Terraform lock table"
    }
  }
}
