# DigitalOcean Supabase

## Manual Steps
Create 2 do_tokens - 1 for terraform and another for nginx
Create domain in DO and change nameservers in domain registrar
Create SendGrid api token and Single Sender Verification
_Optional_
If using Terraform cloud create terraform cloud api key


## Terraform documentation

- The Infra subdirectory has its own `README.md` file containing basic information about the infrastructure created
- Inputs and Outputs will be automatically documented using pre-commit hooks in the `README.md` file
  - To automatically create the documentation you need to install the hooks as described below and have the following text within the `README.md` file:
  ```md
  <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
  <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
  ```
- The subdirectory has a `terraform.tfvars.example` file holding example values for variables required to implement the infrastructure. This implementation should be used for local testing only and **should not be used for production-grade implementations.**

## Hooks

Install `pre-commit` and `terraform-docs` (on MacOS, Homebrew has formulae for both).

You can install the pre-commit hooks by running `pre-commit install`.


## Output from Packer
```
    digitalocean.supabase: Docker Compose version v2.15.1
==> digitalocean.supabase: Gracefully shutting down droplet...
==> digitalocean.supabase: Creating snapshot: supabase-20230123105559
==> digitalocean.supabase: Waiting for snapshot to complete...
==> digitalocean.supabase: Destroying droplet...
==> digitalocean.supabase: Deleting temporary ssh key...
Build 'digitalocean.supabase' finished after 5 minutes 8 seconds.

==> Wait completed after 5 minutes 8 seconds

==> Builds finished. The artifacts of successful builds are:
--> digitalocean.supabase: A snapshot was created: 'supabase-20230123105559' (ID: 125471854) in regions 'ams3'
```