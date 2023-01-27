output "psql_pass" {
  value     = random_password.psql.result
  sensitive = true
}

output "htpasswd" {
  value     = random_password.htpasswd.result
  sensitive = true
}

output "sendgrid_generated_api" {
  value     = sendgrid_api_key.this.api_key
  sensitive = true
}

output "jwt" {
  value     = random_password.jwt.result
  sensitive = true
}

output "jwt_anon" {
  value     = jwt_hashed_token.anon.token
  sensitive = true
}

output "jwt_service_role" {
  value     = jwt_hashed_token.service_role.token
  sensitive = true
}

output "droplet_volume_id" {
  value = digitalocean_volume.this.id
}

output "reserved_ip" {
  value = digitalocean_reserved_ip.this.ip_address
}

output "bucket" {
  value = digitalocean_spaces_bucket.this.name
}
