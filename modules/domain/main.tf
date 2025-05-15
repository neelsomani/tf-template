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

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options :
    dvo.resource_record_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.public.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
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
