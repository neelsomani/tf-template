terraform {
  backend "s3" {
    bucket         = data.terraform_remote_state.global.outputs.prod_terraform_bucket_name
    key            = "tf/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-prod"
  }
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
