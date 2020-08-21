locals {
  hostname_enabled = var.friendly_hostname != null

  friendly_hostname          = local.hostname_enabled ? var.friendly_hostname : { host = "", acm_certificate_arn = "" }
  friendly_hostname_base_url = local.hostname_enabled ? "https://${local.friendly_hostname.host}" : ""
}
