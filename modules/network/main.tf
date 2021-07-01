locals {
  is_new_vpc = var.use_existing_vpc ? 0 : 1
  name       = "${var.identifier}-${var.vpc_network}"
}

resource "google_compute_network" "vpc" {
  name                    = var.vpc_network
  auto_create_subnetworks = false
  count                   = local.is_new_vpc
}

data "google_compute_network" "vpc_state" {
  name = var.vpc_network
  depends_on = [
    google_compute_network.vpc
  ]
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${local.name}-subnet"
  ip_cidr_range = var.network_cidr
  network       = data.google_compute_network.vpc_state.id
  region        = var.region
  count         = local.is_new_vpc
  # private_ip_google_access = "${var.internetless}"
}

resource "google_compute_router" "router" {
  name    = "${local.name}-router"
  region  = var.region
  network = data.google_compute_network.vpc_state.id
  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${local.name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "web_svc" {
  name    = "${local.name}-web-svc"
  network = data.google_compute_network.vpc_state.id
  allow {
    protocol = "tcp"
    ports    = ["9000", "7000", "6379", "9042", "5433", "22"]
  }
  target_tags   = compact(var.target_tags)
  source_ranges = [var.ingress_cidr]
}

resource "google_compute_firewall" "intra_svc" {
  name    = "${local.name}-intra-svc"
  network = data.google_compute_network.vpc_state.id
  allow {
    protocol = "tcp"
    ports    = ["7100", "9100"]
  }
  target_tags   = compact(var.target_tags)
  source_ranges = [var.network_cidr]
}

resource "google_compute_firewall" "ssh" {
  name    = "${local.name}-ssh"
  network = data.google_compute_network.vpc_state.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags   = compact(["${var.identifier}-bastion"])
  source_ranges = [var.ingress_cidr]
  count = var.bastion_create ? 1 : 0
}
