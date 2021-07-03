locals {
  name        = var.dns_on ? "${var.identifier}-${var.zone}" : "${var.zone}"
  root_domain = "${var.identifier}.${var.domain}"
}

resource "google_dns_managed_zone" "dns_zone" {
  name     = local.name
  dns_name = "${local.root_domain}."
  count    = var.dns_on ? 1 : 0
}

data "google_dns_managed_zone" "dns_zone" {
  name  = local.name
  count = var.dns_on ? 0 : 1
}

resource "google_dns_record_set" "platform_ops" {
  name         = var.dns_on ? "${var.hostname}-${count.index}.${google_dns_managed_zone.dns_zone[0].dns_name}" : "${var.hostname}-${count.index}.${var.identifier}.${data.google_dns_managed_zone.dns_zone[0].dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_on ? google_dns_managed_zone.dns_zone[0].name : data.google_dns_managed_zone.dns_zone[0].name
  rrdatas      = ["${var.ip_to_dns[count.index]}"]
  count        = length(var.ip_to_dns)
}
