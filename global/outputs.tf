output "domain"      { value = module.global.domain }
output "zone_id"     { value = module.global.zone_id }
output "cert_arn"    { value = module.global.cert_arn }
output "prod_terraform_bucket_name" {
  value = aws_s3_bucket.terraform_prod.bucket
}

output "dev_terraform_bucket_name" {
  value = aws_s3_bucket.terraform_dev.bucket
}
