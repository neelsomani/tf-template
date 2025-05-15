########################################################
# 1. Register the domain in Route 53 Domains
########################################################
resource "aws_route53domains_domain" "this" {
  provider = aws.route53_domains_region

  domain_name = var.domain_name
  auto_renew  = false # keep it active each year

  # === You MUST supply real contact info. Example variables shown ===
  admin_contact {
    address_line_1 = var.address1
    city           = var.city
    contact_type   = "PERSON"
    country_code   = var.country_code # "US", "CA", …
    state          = var.state
    zip_code       = var.postal_code
    email          = var.email
    first_name     = var.first_name
    last_name      = var.last_name
    phone_number   = var.phone_number # "+1.5551234567"
  }

  registrant_contact {
    address_line_1 = var.address1
    city           = var.city
    contact_type   = "PERSON"
    country_code   = var.country_code # "US", "CA", …
    state          = var.state
    zip_code       = var.postal_code
    email          = var.email
    first_name     = var.first_name
    last_name      = var.last_name
    phone_number   = var.phone_number # "+1.5551234567"
  }
  tech_contact {
    address_line_1 = var.address1
    city           = var.city
    contact_type   = "PERSON"
    country_code   = var.country_code # "US", "CA", …
    state          = var.state
    zip_code       = var.postal_code
    email          = var.email
    first_name     = var.first_name
    last_name      = var.last_name
    phone_number   = var.phone_number # "+1.5551234567"
  }
}

########################################################
# 2. Create a public hosted zone for the domain
########################################################
resource "aws_route53_zone" "public" {
  name       = var.domain_name
  depends_on = [aws_route53domains_domain.this]
}

########################################################
# 3. Request an ACM cert + automatically validate via DNS
########################################################
resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  lifecycle { create_before_destroy = true }
}

locals {
  # Prepare a list of all potential DNS validation records based on ACM's domain_validation_options.
  # Each item in the list is a map representing the properties of a DNS record.
  temp_validation_records_list = [
    for dvo in aws_acm_certificate.cert.domain_validation_options : {
      # dvo.resource_record_name is the FQDN of the DNS record (e.g., _x123.example.com.)
      # dvo.resource_record_type is the DNS record type (e.g., CNAME)
      # dvo.resource_record_value is the DNS record value (e.g., _y456.acm-validation.aws.)
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      records = [dvo.resource_record_value] # aws_route53_record expects a list for 'records'
    }
  ]

  # De-duplicate the list of record specifications.
  # distinct() will remove entries where all fields (name, type, records) are identical.
  # This handles cases where ACM suggests the same DNS record for multiple domain names (e.g., example.com and *.example.com).
  unique_validation_records_list = distinct(local.temp_validation_records_list)

  # Convert the unique list of record specifications into a map suitable for for_each.
  # The key of this map will be the DNS record's FQDN (dvo.resource_record_name),
  # which is unique within the unique_validation_records_list.
  # The value will be a map containing the type and records for the DNS entry.
  cert_validation_dns_records_map = {
    for rec_spec in local.unique_validation_records_list :
    rec_spec.name => { # Use the record FQDN as the key for the for_each map
      type    = rec_spec.type
      records = rec_spec.records
    }
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = local.cert_validation_dns_records_map

  zone_id = aws_route53_zone.public.zone_id
  name    = each.key # This is rec_spec.name (the FQDN of the DNS record)
  type    = each.value.type
  ttl     = 60
  records = each.value.records # This is a list containing the record value
}

resource "aws_route53_record" "vercel_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "@"
  type    = "A"
  ttl     = 60
  records = ["76.76.21.21"]
}

resource "aws_route53_record" "www_cname" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 300
  records = ["cname.vercel-dns.com."]
}


resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}
