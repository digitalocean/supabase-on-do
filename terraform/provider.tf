terraform {
  required_version = "~> 1.5.1"

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
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.spaces_access_key_id
  spaces_secret_key = var.spaces_secret_access_key
}

provider "sendgrid" {
  api_key = var.sendgrid_api
}

############
# Choose between local or cloud state storage
############

# IMP. If using local state file management make sure you DO NOT upload your state file in version control as this stores sensitive data
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

# # If you decide to store your state file within Terraform Cloud
# # - Comment the local backend block above
# # - Uncomment the cloud backend block below and modify the organization and workspaces options
# # - Uncomment the `tf_token` variable block within the `variables.tf` file
# # - Provide the varibale value accordingly (IMP. Secrets shouldn't be stored in version control)
# terraform {
#   cloud {
#     organization = "name-of-org"

#     workspaces {
#       tags = ["supabase"]
#     }

#     token = var.tf_token
#   }
# }
