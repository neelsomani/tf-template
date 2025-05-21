terraform {
  backend "s3" {
    bucket         = "<insert terraform bucket name>"
    key            = "tf/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-dev"
  }
}

data "terraform_remote_state" "global" {
  backend = "s3"

  config = {
    bucket = "<insert global bucket name>"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}