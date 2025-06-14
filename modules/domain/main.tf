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

# 2b.  Delegate the registered domain to the hosted-zone NS set
resource "aws_route53domains_registered_domain" "this" {
  domain_name = aws_route53domains_domain.this.domain_name   # same domain

  # Copy the NS values that Route 53 assigned to the zone
  dynamic "name_server" {
    for_each = aws_route53_zone.public.name_servers
    content {
      name = name_server.value
    }
  }

  depends_on = [aws_route53_zone.public]                      # wait for the zone
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
  count = length(distinct([
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.resource_record_name
  ]))

  allow_overwrite = true
  zone_id         = aws_route53_zone.public.zone_id
  name            = tolist(distinct([for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.resource_record_name]))[count.index]
  type            = tolist(distinct([for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.resource_record_type]))[count.index]
  ttl             = 60
  records         = [tolist(distinct([for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.resource_record_value]))[count.index]]
}

resource "aws_route53_record" "vercel_a" {
  zone_id = aws_route53_zone.public.zone_id
  name    = ""
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
