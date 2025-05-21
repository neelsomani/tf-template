terraform {
  backend "s3" {
    bucket         = data.terraform_remote_state.global.outputs.dev_terraform_bucket_name
    key            = "tf/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-dev"
  }
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
