resource "random_id" "bucket" {
  byte_length = 8
  prefix      = "supabase-"
}


resource "digitalocean_spaces_bucket" "this" {
  name   = random_id.bucket.hex
  region = var.region
}

resource "digitalocean_spaces_bucket_policy" "this" {
  region = digitalocean_spaces_bucket.this.region
  bucket = digitalocean_spaces_bucket.this.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "IPAllow",
        "Effect" : "Deny",
        "Principal" : "*",
        "Action" : "s3:*",
        "Resource" : [
          "arn:aws:s3:::${digitalocean_spaces_bucket.this.name}",
          "arn:aws:s3:::${digitalocean_spaces_bucket.this.name}/*"
        ],
        "Condition" : {
          "NotIpAddress" : {
            "aws:SourceIp" : "${local.spaces_ip_range}"
          }
        }
      }
    ]
  })
}

resource "digitalocean_volume" "this" {
  region                  = var.region
  name                    = "supabase-volume"
  size                    = var.volume_size
  initial_filesystem_type = "ext4"
  description             = "Supabase PostgreSQL Persistant Volume."
}

