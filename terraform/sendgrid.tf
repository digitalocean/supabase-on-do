############
# This is a bit of a hack, as using the null_resource should be a last option
# If one of the sendgrid terraform providers ever supports creating Single Sender Virifaction this can be removed and replaced with the specific resource
############
resource "null_resource" "sendgrid_single_sender" {
  provisioner "local-exec" {
    command = "cp ./files/sender-verification.sh.tmpl ./files/sender-verification.sh && chmod +x ./files/sender-verification.sh && ./files/sender-verification.sh"

    environment = {
      API           = var.sendgrid_api
      NICKNAME      = local.smtp_nickname
      USER          = var.smtp_admin_user
      SENDER        = local.smtp_sender_name
      REPLY_TO      = local.smtp_reply_to
      REPLY_TO_NAME = local.smtp_reply_to_name
      ADDR          = var.smtp_addr
      ADDR_2        = var.smtp_addr_2
      STATE         = var.smtp_state
      CITY          = var.smtp_city
      COUNTRY       = var.smtp_country
      ZIP_CODE      = var.smtp_zip_code
    }
  }
}

resource "sendgrid_domain_authentication" "this" {
  domain             = var.domain
  automatic_security = false
  valid              = true
}

resource "sendgrid_link_branding" "this" {
  domain = var.domain
  valid  = true
}

resource "digitalocean_record" "domain_auth_0" {
  domain   = var.domain
  type     = upper(sendgrid_domain_authentication.this.dns[0].type)
  name     = trimsuffix(sendgrid_domain_authentication.this.dns[0].host, ".${var.domain}")
  value    = sendgrid_domain_authentication.this.dns[0].data
  priority = upper("${sendgrid_domain_authentication.this.dns[0].type}") == "MX" ? 10 : null
  ttl      = local.ttl[upper(sendgrid_domain_authentication.this.dns[0].type)]
}

resource "digitalocean_record" "domain_auth_1" {
  domain   = var.domain
  type     = upper(sendgrid_domain_authentication.this.dns[1].type)
  name     = trimsuffix(sendgrid_domain_authentication.this.dns[1].host, ".${var.domain}")
  value    = sendgrid_domain_authentication.this.dns[1].data
  priority = upper("${sendgrid_domain_authentication.this.dns[1].type}") == "MX" ? 10 : null
  ttl      = local.ttl[upper(sendgrid_domain_authentication.this.dns[1].type)]
}

resource "digitalocean_record" "domain_auth_2" {
  domain   = var.domain
  type     = upper(sendgrid_domain_authentication.this.dns[2].type)
  name     = trimsuffix(sendgrid_domain_authentication.this.dns[2].host, ".${var.domain}")
  value    = sendgrid_domain_authentication.this.dns[2].data
  priority = upper("${sendgrid_domain_authentication.this.dns[2].type}") == "MX" ? 10 : null
  ttl      = local.ttl[upper(sendgrid_domain_authentication.this.dns[2].type)]
}

resource "digitalocean_record" "link_brand_0" {
  domain = var.domain
  type   = upper("${sendgrid_link_branding.this.dns[0].type}")
  name   = trimsuffix(sendgrid_link_branding.this.dns[0].host, ".${var.domain}")
  value  = upper("${sendgrid_link_branding.this.dns[0].type}") == "CNAME" ? "${sendgrid_link_branding.this.dns[0].data}." : sendgrid_link_branding.this.dns[0].data
  ttl    = local.ttl[upper(sendgrid_link_branding.this.dns[0].type)]
}

resource "digitalocean_record" "link_brand_1" {
  domain = var.domain
  type   = upper("${sendgrid_link_branding.this.dns[1].type}")
  name   = trimsuffix(sendgrid_link_branding.this.dns[1].host, ".${var.domain}")
  value  = upper("${sendgrid_link_branding.this.dns[1].type}") == "CNAME" ? "${sendgrid_link_branding.this.dns[1].data}." : sendgrid_link_branding.this.dns[1].data
  ttl    = local.ttl[upper(sendgrid_link_branding.this.dns[1].type)]
}

resource "sendgrid_api_key" "this" {
  name = "supabase-api-key"
  scopes = [
    "mail.send"
  ]
}
