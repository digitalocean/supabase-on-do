resource "random_password" "psql" {
  length           = 16
  special          = true
  override_special = "-_"
}

resource "random_password" "htpasswd" {
  length           = 16
  special          = true
  override_special = "-_"
}

resource "htpasswd_password" "hash" {
  password = random_password.htpasswd.result

  lifecycle {
    ignore_changes = [password]
  }
}

resource "random_password" "jwt" {
  length           = 32
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
      iat  = 1674514800
      exp  = 1832281200
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
      iat  = 1674514800
      exp  = 1832281200
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
