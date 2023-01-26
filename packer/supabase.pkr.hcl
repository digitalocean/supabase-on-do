packer {
  required_version = "~> 1.8.5"

  required_plugins {
    digitalocean = {
      version = "1.1.1"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

# # Use can also set DIGITALOCEAN_TOKEN, SPACES_ACCESS_KEY_ID and SPACES_SECRET_ACCESS_KEY env variables
# # Set the variable value in *.auto.pkvars.hcl file
# # or using -var "do_token=..." CLI option
# # variable "do_token" {}

variable "region" {
  description = "The region where the Droplet will be created."
  type        = string
}

variable "droplet_image" {
  description = "The Droplet image ID or slug. This could be either image ID or droplet snapshot ID."
  type        = string
  default     = "ubuntu-22-10-x64"
}

variable "droplet_size" {
  description = "The unique slug that indentifies the type of Droplet."
  type        = string
  default     = "s-1vcpu-1gb"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  snapshot_name = "supabase-${local.timestamp}"

  tags = [
    "supabase",
    "digitalocean",
    "packer"
  ]
}

source "digitalocean" "supabase" {
  image         = var.droplet_image
  region        = var.region
  size          = var.droplet_size
  snapshot_name = local.snapshot_name
  tags          = local.tags
  ssh_username  = "root"
}

build {
  sources = ["source.digitalocean.supabase"]

  provisioner "file" {
    source      = "./supabase"
    destination = "/root"
  }

  provisioner "shell" {
    script = "./scripts/setup.sh"
  }
}
