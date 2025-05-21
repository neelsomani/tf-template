provider "aws" {
  region  = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "{insert_bucket_name}"
    key            = "tf/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "{insert_table_name}"
  }
}

resource "aws_s3_bucket" "terraform_prod" {
  bucket = "insert globally unique bucket name"
}

resource "aws_dynamodb_table" "terraform-state-prod" {
  name           = "terraform-state-prod"
  read_capacity  = 1
  write_capacity = 1

  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "terraform_dev" {
  bucket = "insert globally unique bucket name"
}

resource "aws_dynamodb_table" "terraform-state-dev" {
  name           = "terraform-state-dev"
  read_capacity  = 1
  write_capacity = 1

  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

module "global" {
  source = "../modules/domain"

  // Insert required variables here
}
