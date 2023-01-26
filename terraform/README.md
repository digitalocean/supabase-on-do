# DigitalOcean Supabase

## Manual Steps
Create do_token
Create domain in DO and change nameservers in domain registrar
Create SendGrid api token and Single Sender Verification
_Optional_
If using Terraform cloud create terraform cloud api key

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.2.0 |
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | ~> 2.25.0 |
| <a name="provider_htpasswd"></a> [htpasswd](#provider\_htpasswd) | 1.0.4 |
| <a name="provider_jwt"></a> [jwt](#provider\_jwt) | 1.1.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |
| <a name="provider_sendgrid"></a> [sendgrid](#provider\_sendgrid) | 0.2.0 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_user"></a> [auth\_user](#input\_auth\_user) | The username for Nginx authentication. | `string` | n/a | yes |
| <a name="input_do_token"></a> [do\_token](#input\_do\_token) | DO API token with read and write permissions. | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain Name where the Supabase instance is accesable. The final domain will be of the foramt `supabase.example.com` | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region where the Droplet will be created. | `string` | n/a | yes |
| <a name="input_sendgrid_api"></a> [sendgrid\_api](#input\_sendgrid\_api) | SendGrid API Key. | `string` | n/a | yes |
| <a name="input_smtp_addr"></a> [smtp\_addr](#input\_smtp\_addr) | Company Address of the Verified Sender. Max 100 chracters. If more is needed use `smtp_addr_2` | `string` | n/a | yes |
| <a name="input_smtp_admin_user"></a> [smtp\_admin\_user](#input\_smtp\_admin\_user) | `From` email address for all emails sent. | `string` | n/a | yes |
| <a name="input_smtp_city"></a> [smtp\_city](#input\_smtp\_city) | Company city of the verified sender. | `string` | n/a | yes |
| <a name="input_smtp_country"></a> [smtp\_country](#input\_smtp\_country) | Company country of the verified sender. | `string` | n/a | yes |
| <a name="input_spaces_access_key_id"></a> [spaces\_access\_key\_id](#input\_spaces\_access\_key\_id) | Access key ID used for Spaces API operations. | `string` | n/a | yes |
| <a name="input_spaces_secret_access_key"></a> [spaces\_secret\_access\_key](#input\_spaces\_secret\_access\_key) | Secret access key used for Spaces API operations. | `string` | n/a | yes |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone to use for Nginx (e.g. Europe/Amsterdam). | `string` | n/a | yes |
| <a name="input_droplet_backups"></a> [droplet\_backups](#input\_droplet\_backups) | Boolean controlling if backups are made. Defaults to true. | `bool` | `true` | no |
| <a name="input_droplet_image"></a> [droplet\_image](#input\_droplet\_image) | The Droplet image ID or slug. This could be either image ID or droplet snapshot ID. | `string` | `"ubuntu-22-10-x64"` | no |
| <a name="input_droplet_size"></a> [droplet\_size](#input\_droplet\_size) | The unique slug that indentifies the type of Droplet. | `string` | `"s-1vcpu-2gb"` | no |
| <a name="input_smtp_addr_2"></a> [smtp\_addr\_2](#input\_smtp\_addr\_2) | Company Address Line 2. Max 100 chracters. | `string` | `""` | no |
| <a name="input_smtp_host"></a> [smtp\_host](#input\_smtp\_host) | The external mail server hostname to send emails through. | `string` | `"smtp.sendgrid.net"` | no |
| <a name="input_smtp_nickname"></a> [smtp\_nickname](#input\_smtp\_nickname) | Nickname to show recipent. Defaults to `smtp_sender_name` or the email address specified in the `smtp_admin_user` variable if neither are specified. | `string` | `""` | no |
| <a name="input_smtp_port"></a> [smtp\_port](#input\_smtp\_port) | Port number to connect to the external mail server on. | `number` | `465` | no |
| <a name="input_smtp_reply_to"></a> [smtp\_reply\_to](#input\_smtp\_reply\_to) | Email address to show in the `reply-to` field within an email. Defaults to the email address specified in the `smtp_admin_user` variable. | `string` | `""` | no |
| <a name="input_smtp_reply_to_name"></a> [smtp\_reply\_to\_name](#input\_smtp\_reply\_to\_name) | Friendly name to show recipent rather than email address in the `reply-to` field within an email. Defaults to `smtp_sender_name` or `smtp_reply_to` if `smtp_sender_name` is not set, or the email address specified in the `smtp_admin_user` variable if neither are specified. | `string` | `""` | no |
| <a name="input_smtp_sender_name"></a> [smtp\_sender\_name](#input\_smtp\_sender\_name) | Friendly name to show recipent rather than email address. Defaults to the email address specified in the `smtp_admin_user` variable. | `string` | `""` | no |
| <a name="input_smtp_state"></a> [smtp\_state](#input\_smtp\_state) | Company State. | `string` | `""` | no |
| <a name="input_smtp_user"></a> [smtp\_user](#input\_smtp\_user) | The username to use for mail server requires authentication | `string` | `"apikey"` | no |
| <a name="input_smtp_zip_code"></a> [smtp\_zip\_code](#input\_smtp\_zip\_code) | Company Zip Code. | `string` | `""` | no |
| <a name="input_spaces_restrict_ip"></a> [spaces\_restrict\_ip](#input\_spaces\_restrict\_ip) | Boolean signifying wether to restrict the spaces bucket to the droplet and reserved ips (as well as the ssh ips if set) or allow all ips. (N.B. If Enabled this will also disable Bucket access from DO's UI.) | `bool` | `false` | no |
| <a name="input_ssh_ip_range"></a> [ssh\_ip\_range](#input\_ssh\_ip\_range) | An array of strings containing the IPv4 addresses and/or IPv4 CIDRs from which the inbound traffic will be accepted. Defaults to ALL IPv4s but it is highly suggested to choose a smaller subset. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | A list of SSH key IDs or fingerprints to enable in the format [12345, 123456]. Only one of `var.ssh_keys` or `var.ssh_pub_file` needs to be specified and should be used. | `list(string)` | `[]` | no |
| <a name="input_ssh_pub_file"></a> [ssh\_pub\_file](#input\_ssh\_pub\_file) | The path to the public key ssh file. Only one of var.ssh\_pub\_file or var.ssh\_keys needs to be specified and should be used. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A list of the tags to be added to the default (`["supabase", "digitalocean", "terraform"]`) Droplet tags. | `list(string)` | `[]` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | The size of the block storage volume in GiB. If updated, can only be expanded. | `number` | `25` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | n/a |
| <a name="output_droplet_voluem_id"></a> [droplet\_voluem\_id](#output\_droplet\_voluem\_id) | n/a |
| <a name="output_htpasswd"></a> [htpasswd](#output\_htpasswd) | n/a |
| <a name="output_jwt"></a> [jwt](#output\_jwt) | n/a |
| <a name="output_jwt_anon"></a> [jwt\_anon](#output\_jwt\_anon) | n/a |
| <a name="output_jwt_service_role"></a> [jwt\_service\_role](#output\_jwt\_service\_role) | n/a |
| <a name="output_psql_pass"></a> [psql\_pass](#output\_psql\_pass) | n/a |
| <a name="output_reserved_ip"></a> [reserved\_ip](#output\_reserved\_ip) | n/a |
| <a name="output_sendgrid_generated_api"></a> [sendgrid\_generated\_api](#output\_sendgrid\_generated\_api) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->