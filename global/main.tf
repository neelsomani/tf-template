provider "aws" {
  region  = "us-west-2"
}

resource "aws_s3_bucket" "terraform_prod" {
  bucket = "insert globally unique bucket name"
}

resource "aws_s3_bucket" "terraform_dev" {
  bucket = "insert globally unique bucket name"
}

module "global" {
  source = "../modules/domain"

  // Insert required variables here
}
