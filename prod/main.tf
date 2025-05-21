# Look up the caller’s AWS account
data "aws_caller_identity" "current" {}

module "prod" {
  source = "../env"

  environment            = "prod"
  domain_certificate_arn = data.terraform_remote_state.global.outputs.cert_arn
  api_config_file_name   = "./configs/prod/config.json"
  global_zone_id         = data.terraform_remote_state.global.outputs.zone_id
}
