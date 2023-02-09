data "digitalocean_domain" "this" {
  name = var.domain
}

# Wait for the Volume to mount to the Droplet to ensure "Resource Busy" error is not encountered
resource "time_sleep" "wait_20_seconds" {
  depends_on = [digitalocean_droplet.this]

  create_duration = "20s"
}


resource "digitalocean_reserved_ip" "this" {
  droplet_id = digitalocean_droplet.this.id
  region     = var.region

  depends_on = [
    time_sleep.wait_20_seconds
  ]
}

resource "digitalocean_record" "a_record" {
  domain = var.domain
  type   = "A"
  name   = "supabase"
  value  = digitalocean_reserved_ip.this.ip_address
}

resource "digitalocean_firewall" "this" {
  name        = "supabase"
  droplet_ids = [digitalocean_droplet.this.id]

  tags = local.tags

  dynamic "inbound_rule" {
    for_each = local.inbound_rule == null ? [] : local.inbound_rule

    content {
      protocol         = inbound_rule.value.protocol
      port_range       = inbound_rule.value.port_range
      source_addresses = inbound_rule.value.source_addresses
    }
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
