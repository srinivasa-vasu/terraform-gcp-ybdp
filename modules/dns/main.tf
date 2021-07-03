locals {
  name          = var.dns_on ? "${var.identifier}-${var.zone}" : "${var.zone}"
  root_domain   = "${var.identifier}.${var.domain}"
  is_new_domain = var.dns_on ? 1 : 0 # flag to determine new domain
}

resource "google_dns_managed_zone" "dns_zone" {
  name     = local.name
  dns_name = "${local.root_domain}."
  count    = local.is_new_domain
}

data "google_dns_managed_zone" "dns_zone" {
  name     = local.name
}

resource "google_dns_record_set" "platform_ops" {
  name         = "${var.hostname}.${data.google_dns_managed_zone.dns_zone.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  rrdatas      = ["${var.dns_to_ip}"]
  # count        = local.is_new_domain
}
