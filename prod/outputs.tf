output "db_instance_uri" {
  value = module.prod.db_instance_uri
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}
