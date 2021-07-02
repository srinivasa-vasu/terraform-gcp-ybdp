locals {
  name          = "${var.identifier}-${var.local_identifier}"
  root_domain   = "${var.identifier}.${var.domain}"
  is_new_domain = var.dns_on ? 1 : 0 # flag to determine new domain
}

resource "google_dns_managed_zone" "dns_zone" {
  name     = local.name
  dns_name = "${local.root_domain}."
  count    = local.is_new_domain
}

resource "google_dns_record_set" "platform_ops" {
  name         = "platformops.${google_dns_managed_zone.dns_zone[count.index].dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.dns_zone[count.index].name
  rrdatas      = ["${var.dns_to_ip}"]
  count        = local.is_new_domain
}
