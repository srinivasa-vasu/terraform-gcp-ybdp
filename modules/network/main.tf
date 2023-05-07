locals {
  is_new_vpc = var.vpc_on ? 1 : 0 # flag to determine new/existing vpc
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

resource "google_compute_subnetwork" "control_subnet" {
  name          = "${local.name}-control"
  ip_cidr_range = var.control_subnet_cidr
  network       = data.google_compute_network.vpc_state.id
  region        = var.region
  count         = local.is_new_vpc
}

resource "google_compute_subnetwork" "universe_subnet" {
  name          = "${local.name}-universe"
  ip_cidr_range = var.universe_subnet_cidr
  network       = data.google_compute_network.vpc_state.id
  region        = var.region
  count         = local.is_new_vpc
}

resource "google_compute_subnetwork" "additional_universe_subnet" {
  name          = "${local.name}-universe"
  ip_cidr_range = element(var.additional_universe_subnet_cidr, count.index)
  network       = data.google_compute_network.vpc_state.id
  region        = element(var.additional_regions, count.index)
  count         = length(var.additional_regions)
}

resource "google_compute_router" "router" {
  name    = "${local.name}-router"
  region  = var.region
  network = data.google_compute_network.vpc_state.id
  bgp {
    asn = 64514
  }
}

# NAT instance to proxy internet connection from the platform network instances
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
