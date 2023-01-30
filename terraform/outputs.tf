output "psql_pass" {
  description = "Randomly generated 32 character password for the Postgres database."
  value       = random_password.psql.result
  sensitive   = true
}

output "htpasswd" {
  description = "Randomly generated 32 character password for authentication via Nginx."
  value       = random_password.htpasswd.result
  sensitive   = true
}

output "sendgrid_generated_api" {
  description = "SendGrid API key to allow sending of emails (The api key is limited to Send Mail scope only)."
  value       = sendgrid_api_key.this.api_key
  sensitive   = true
}

output "jwt" {
  description = "Randomly generated 40 character jwt secret."
  value       = random_password.jwt.result
  sensitive   = true
}

output "jwt_iat" {
  description = "The Issued At time for the `anon` and `service_role` jwt tokens in epoch time."
  value       = time_static.jwt_iat.unix
}

output "jwt_exp" {
  description = "The Expiration time for the `anon` and `service_role` jwt tokens in epoch time."
  value       = time_static.jwt_exp.unix
}

output "jwt_anon" {
  description = "The HS256 generated jwt token for the `anon` role."
  value       = jwt_hashed_token.anon.token
  sensitive   = true
}

output "jwt_service_role" {
  description = "The HS256 generated jwt token for the `service_role` role."
  value       = jwt_hashed_token.service_role.token
  sensitive   = true
}

output "droplet_volume_id" {
  description = "The unique identifier for the volume attached to the droplet."
  value       = digitalocean_volume.this.id
}

output "reserved_ip" {
  description = "The Reserved IP assigned to the droplet."
  value       = digitalocean_reserved_ip.this.ip_address
}

output "bucket" {
  description = "The unique name of the bucket in the format `supabase-ab12cd34ef56gh78`."
  value       = digitalocean_spaces_bucket.this.name
}
