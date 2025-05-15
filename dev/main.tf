# Look up the caller’s AWS account
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "global" {
  backend = "local"

  config = {
    path = "../global/terraform.tfstate"
  }
}

module "dev" {
  source = "../env"

  environment            = "dev"
  domain_certificate_arn = data.terraform_remote_state.global.outputs.cert_arn
  api_config_file_name   = "./configs/dev/config.json"
  global_zone_id         = data.terraform_remote_state.global.outputs.zone_id
}
