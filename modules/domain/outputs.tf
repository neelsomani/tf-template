output "domain"      { value = var.domain_name }
output "zone_id"     { value = aws_route53_zone.public.zone_id }
output "cert_arn"    { value = aws_acm_certificate_validation.cert.certificate_arn }
