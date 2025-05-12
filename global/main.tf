provider "aws" {
  region  = "us-west-2"
}

module "global" {
  source = "../modules/domain"

  // Insert required variables here
}
