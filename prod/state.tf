terraform {
  backend "s3" {
    bucket         = "<insert terraform bucket name>"
    key            = "tf/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-prod"
  }
}
