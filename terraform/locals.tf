resource "random_password" "psql" {
  length           = 32
  special          = true
  override_special = "-_"
}

resource "random_password" "htpasswd" {
  length           = 32
  special          = true
  override_special = "-_"
}

resource "htpasswd_password" "hash" {
  password = random_password.htpasswd.result

  lifecycle {
    ignore_changes = [password]
  }
}

resource "time_static" "jwt_iat" {}

resource "time_static" "jwt_exp" {
  rfc3339 = timeadd(time_static.jwt_iat.rfc3339, "43829h") # Add 5 Years
}

resource "random_password" "jwt" {
  length           = 40
  special          = true
  override_special = "-_"
}

resource "jwt_hashed_token" "anon" {
  secret    = random_password.jwt.result
  algorithm = "HS256"
  claims_json = jsonencode(
    {
      role = "anon"
      iss  = "supabase"
      iat  = time_static.jwt_iat.unix
      exp  = time_static.jwt_exp.unix
    }
  )
}

resource "jwt_hashed_token" "service_role" {
  secret    = random_password.jwt.result
  algorithm = "HS256"
  claims_json = jsonencode(
    {
      role = "service_role"
      iss  = "supabase"
      iat  = time_static.jwt_iat.unix
      exp  = time_static.jwt_exp.unix
    }
  )
}

locals {
  default_tags = [
    "supabase",
    "digitalocean",
    "terraform"
  ]

  ssh_ip_range_spaces = var.ssh_ip_range == ["0.0.0.0/0"] ? [] : var.ssh_ip_range

  spaces_restricted_ip_range = concat(
    ["${digitalocean_droplet.this.ipv4_address}"],
    ["${digitalocean_reserved_ip.this.ip_address}"],
    local.ssh_ip_range_spaces
  )

  spaces_ip_range = var.spaces_restrict_ip ? local.spaces_restricted_ip_range : ["0.0.0.0/0", "::/0"]

  inbound_rule_ssh = var.enable_ssh ? [{
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_ip_range
  }] : []

  inbound_rule_db = var.enable_db_con ? [{
    protocol         = "tcp"
    port_range       = "5432"
    source_addresses = var.db_ip_range
  }] : []

  inbound_rule = concat(
    local.inbound_rule_ssh,
    local.inbound_rule_db
  )

  tags = concat(
    local.default_tags,
    var.tags
  )

  ttl = {
    "A"     = 1800
    "CNAME" = 43200
    "MX"    = 14400
    "TXT"   = 3600
  }

  ssh_fingerprints = var.ssh_keys != [""] ? var.ssh_keys : [digitalocean_ssh_key.this[0].fingerprint]

  smtp_sender_name   = var.smtp_sender_name != "" ? var.smtp_sender_name : var.smtp_admin_user
  smtp_nickname      = var.smtp_nickname != "" ? var.smtp_nickname : var.smtp_sender_name != "" ? var.smtp_sender_name : var.smtp_admin_user
  smtp_reply_to      = var.smtp_reply_to != "" ? var.smtp_reply_to : var.smtp_admin_user
  smtp_reply_to_name = var.smtp_reply_to_name != "" ? var.smtp_reply_to_name : var.smtp_sender_name != "" ? var.smtp_sender_name : var.smtp_admin_user

  env_file = templatefile("${path.module}/files/.env.tftpl",
    {
      TF_PSQL_PASS                = "${random_password.psql.result}",
      TF_JWT_SECRET               = "${random_password.jwt.result}",
      TF_ANON_KEY                 = "${jwt_hashed_token.anon.token}",
      TF_SERVICE_ROLE_KEY         = "${jwt_hashed_token.service_role.token}",
      TF_DOMAIN                   = "${var.domain}",
      TF_SITE_URL                 = "${var.site_url}",
      TF_TIMEZONE                 = "${var.timezone}",
      TF_REGION                   = "${var.region}",
      TF_SPACES_BUCKET            = "${digitalocean_spaces_bucket.this.name}",
      TF_SPACES_ACCESS_KEY_ID     = "${var.spaces_access_key_id}",
      TF_SPACES_SECRET_ACCESS_KEY = "${var.spaces_secret_access_key}",
      TF_SMTP_ADMIN_EMAIL         = "${var.smtp_admin_user}",
      TF_SMTP_HOST                = "${var.smtp_host}",
      TF_SMTP_PORT                = "${var.smtp_port}",
      TF_SMTP_USER                = "${var.smtp_user}",
      TF_SMTP_PASS                = "${sendgrid_api_key.this.api_key}",
      TF_SMTP_SENDER_NAME         = "${local.smtp_sender_name}",
      TF_DEFAULT_ORGANIZATION     = "${var.studio_org}",
      TF_DEFAULT_PROJECT          = "${var.studio_project}",
    }
  )

  do_ini = templatefile("${path.module}/files/digitalocean.ini.tftpl", { TF_DIGITALOCEAN_TOKEN = "${var.do_token}" })

  htpasswd = templatefile("${path.module}/files/.htpasswd.tftpl",
    {
      AUTH_USER = "${var.auth_user}",
      AUTH_PASS = "${htpasswd_password.hash.apr1}"
    }
  )

  kong_file = templatefile("${path.module}/files/kong.yml.tftpl",
    {
      TF_ANON_KEY         = "${jwt_hashed_token.anon.token}",
      TF_SERVICE_ROLE_KEY = "${jwt_hashed_token.service_role.token}",
    }
  )

  cloud_config = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/root/supabase/.env"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = base64encode("${local.env_file}")
    },
    {
      path        = "/root/supabase/digitalocean.ini"
      permissions = "0600"
      owner       = "root:root"
      encoding    = "b64"
      content     = base64encode("${local.do_ini}")
    },
    {
      path        = "/root/supabase/.htpasswd"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = base64encode("${local.htpasswd}")
    },
    {
      path        = "/root/supabase/volumes/api/kong.yml"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = base64encode("${local.kong_file}")
    },
  ]
})}
  END
}
