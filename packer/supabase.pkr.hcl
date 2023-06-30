packer {
  required_version = "~> 1.9.1"

  required_plugins {
    digitalocean = {
      version = "1.1.1"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

# Set the variable value in the supabase.auto.pkvars.hcl file
# or use -var "do_token=..." CLI option
variable "do_token" {
  description = "DO API token with read and write permissions."
  type        = string
  sensitive   = true
}

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
  description = "The unique slug that identifies the type of Droplet."
  type        = string
  default     = "c-2"
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
  api_token     = var.do_token
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
