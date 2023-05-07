locals {
  name                        = var.dns_on ? "${var.identifier}-${var.zone}" : "${var.zone}"
  root_domain                 = var.domain
  gcp_internal_domain         = "googleapis.com."
  gcp_internal_domain_arecord = "restricted.googleapis.com."
  gcp_internal_domain_cname   = "*.googleapis.com."
  gcp_internal_ips            = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]

}

resource "google_dns_managed_zone" "dns_zone" {
  name     = local.name
  dns_name = "${local.root_domain}."
  count    = var.dns_on ? 1 : 0
}

resource "google_dns_managed_zone" "private_dns_zone" {
  name       = "googleapis-com"
  dns_name   = local.gcp_internal_domain
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = var.vpc_network
    }
  }
  count = var.airgap ? 1 : 0
}

data "google_dns_managed_zone" "dns_zone" {
  name  = local.name
  count = var.dns_on ? 0 : 1
}

resource "google_dns_record_set" "platform_ops" {
  # use index for the secondary instances
  name         = var.dns_on ? ((count.index > 0) ? "${var.hostname}-${count.index}.${google_dns_managed_zone.dns_zone[0].dns_name}" : "${var.hostname}.${google_dns_managed_zone.dns_zone[0].dns_name}") : ((count.index > 0) ? "${var.hostname}-${count.index}.${var.identifier}.${data.google_dns_managed_zone.dns_zone[0].dns_name}" : "${var.hostname}.${var.identifier}.${data.google_dns_managed_zone.dns_zone[0].dns_name}")
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_on ? google_dns_managed_zone.dns_zone[0].name : data.google_dns_managed_zone.dns_zone[0].name
  rrdatas      = ["${var.ip_to_dns[count.index]}"]
  count        = length(var.ip_to_dns)
}

resource "google_dns_record_set" "gcp_internal_domain_arecord" {
  # use index for the secondary instances
  name         = local.gcp_internal_domain_arecord
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.private_dns_zone[count.index].name
  rrdatas      = local.gcp_internal_ips
  count        = var.airgap ? 1 : 0
}

resource "google_dns_record_set" "gcp_internal_domain_cname" {
  # use index for the secondary instances
  name         = local.gcp_internal_domain_cname
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.private_dns_zone[count.index].name
  rrdatas      = [local.gcp_internal_domain_arecord]
  count        = var.airgap ? 1 : 0
}
