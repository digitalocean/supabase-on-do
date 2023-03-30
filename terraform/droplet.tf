data "digitalocean_droplet_snapshot" "supabase" {
  name_regex  = "^supabase-20\\d{12}$"
  region      = var.region
  most_recent = true
}

data "cloudinit_config" "this" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"
    content      = local.cloud_config
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "init.sh"
    content      = <<-EOF
      #!/bin/bash
      mkdir -p /mnt/supabase_volume
      sudo mount -o defaults,nofail,discard,noatime /dev/disk/by-id/scsi-0DO_Volume_supabase-volume /mnt/supabase_volume
      sleep 10
      mkdir -p /mnt/supabase_volume/supabase/data
      cd /root/supabase
      /usr/bin/docker compose -f /root/supabase/docker-compose.yml up -d
    EOF
  }
}

resource "digitalocean_droplet" "this" {
  image      = data.digitalocean_droplet_snapshot.supabase.id
  name       = "supabase-droplet"
  region     = var.region
  size       = var.droplet_size
  monitoring = true
  backups    = var.droplet_backups
  ssh_keys   = local.ssh_fingerprints
  volume_ids = [digitalocean_volume.this.id]
  user_data  = data.cloudinit_config.this.rendered
  tags       = local.tags

  lifecycle {
    ignore_changes = [user_data]
  }
}

resource "digitalocean_ssh_key" "this" {
  count = var.ssh_pub_file == "" ? 0 : 1

  name       = "Supabase Droplet SSH Key"
  public_key = file(var.ssh_pub_file)
}
