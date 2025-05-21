terraform {
  backend "s3" {
    bucket         = data.terraform_remote_state.global.outputs.prod_terraform_bucket_name
    key            = "tf/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = data.terraform_remote_state.global.outputs.prod_terrafrom_dynamo_table_name
  }
}
