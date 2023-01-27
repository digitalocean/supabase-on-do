############
# The Project resource is not working 100% to my liking, so for now it is commented out.
# This is more of a nice to have and therefore will look/debug it at a later stage as I don't want to block releasing this project.
############

# resource "time_sleep" "wait_15_seconds_ip" {
#   create_duration = "15s"

#   depends_on = [
#     time_sleep.wait_20_seconds
#   ]
# }

# resource "digitalocean_project" "supabase" {
#   name        = "Supabase"
#   description = "The project containing the Supabase resources."
#   purpose     = "Supabase Deployment"
#   is_default  = false
#   resources = [
#     digitalocean_droplet.this.urn,
#     data.digitalocean_domain.this.urn,
#     digitalocean_spaces_bucket.this.urn,
#     digitalocean_volume.this.urn
#   ]

#   depends_on = [
#     time_sleep.wait_15_seconds_ip
#   ]
# }
