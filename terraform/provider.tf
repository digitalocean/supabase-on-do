terraform {
  required_version = "~> 1.3.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.25.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    jwt = {
      source  = "camptocamp/jwt"
      version = "1.1.0"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "1.0.4"
    }
    sendgrid = {
      source  = "taharah/sendgrid"
      version = "0.2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "sendgrid" {
  api_key = var.sendgrid_api
}

#Choose between local or cloud state storage
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

# # Use env variable TF_TOKEN_app_terraform_io
# # or the -var="tf_token=..." CLI option
# variable "tf_token" {}

# terraform {
#   cloud {
#     organization = "name-of-org"

#     workspaces {
#       tags = ["supabase"]
#     }

#     token = var.tf_token
#   }
# }
