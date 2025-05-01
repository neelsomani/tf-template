# Look up the caller’s AWS account
data "aws_caller_identity" "current" {}

# Expose it
output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

module "prod" {
  source = "../env"

  environment = "prod"
}
