terraform {
  backend "s3" {
    bucket         = aws_s3_bucket.terraform_global.bucket
    key            = "tf/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-global"
  }
}

resource "aws_dynamodb_table" "terraform-state-global" {
  name           = "terraform-state-global"
  read_capacity  = 1
  write_capacity = 1

  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
