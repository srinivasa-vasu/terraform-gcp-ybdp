locals {
  name               = "${var.identifier}-${var.local_identifier}"
  gcp_internal_range = ["199.36.153.4/30", "142.251.42.116/32"]
  protocol           = "TCP"
}

# Rules to allow access from workstation/external machine ip to the universe services
resource "google_compute_firewall" "web_svc" {
  name    = "${local.name}-web-svc"
  network = var.vpc_nw
  allow {
    protocol = local.protocol
    ports    = ["9000", "7000", "6379", "9042", "5433"]
  }
  # target_tags   = compact(var.target_tags)
  source_ranges = [var.ingress_cidr, var.control_subnet_cidr, var.universe_subnet_cidr]
}

# Rules for intra network comms
resource "google_compute_firewall" "intra_svc" {
  name    = "${local.name}-intra-svc"
  network = var.vpc_nw
  allow {
    protocol = local.protocol
    ports    = ["7100", "9100", "22", "11000", "12000", "13000", "9300", "54422", "18018", "14000"]
  }
  # target_tags   = compact(var.target_tags)
  source_ranges = [var.control_subnet_cidr, var.universe_subnet_cidr]
}

# ssh access to the bastion host, if enabled
resource "google_compute_firewall" "ssh" {
  name    = "${local.name}-ssh"
  network = var.vpc_nw
  allow {
    protocol = local.protocol
    ports    = ["22"]
  }
  target_tags   = compact(["${var.identifier}-bastion"])
  source_ranges = [var.ingress_cidr]
  count         = var.bastion_on ? 1 : 0
}

# Rules to allow access from workstation/external machine ip to the universe services
resource "google_compute_firewall" "allow_all" {
  name    = "${local.name}-allow-all"
  network = var.vpc_nw
  allow {
    protocol = local.protocol
  }
  source_ranges = [var.ingress_cidr]
  count         = var.public_on ? 1 : 0
}

resource "google_compute_firewall" "egress_deny_internet" {
  name    = "${local.name}-airgap-deny-internet"
  network = var.vpc_nw
  deny {
    protocol = "all"
  }
  # disabled           = "true"
  priority           = "1100"
  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  count              = var.airgap ? 1 : 0
}

resource "google_compute_firewall" "egress_airgap_inter_cloudsvc" {
  name    = "${local.name}-airgap-inter-cloudsvc"
  network = var.vpc_nw
  allow {
    protocol = local.protocol
    ports    = ["443"]
  }
  direction          = "EGRESS"
  destination_ranges = local.gcp_internal_range
  count              = var.airgap ? 1 : 0
}

resource "google_compute_firewall" "egress_airgap_intra_svc" {
  name    = "${local.name}-airgap-intra-svc"
  network = var.vpc_nw
  allow {
    protocol = local.protocol
    ports    = ["7100", "9100", "22", "11000", "12000", "13000", "9300", "54422", "18018", "14000", "443"]
  }
  direction          = "EGRESS"
  destination_ranges = [var.control_subnet_cidr, var.universe_subnet_cidr]
  count              = var.airgap ? 1 : 0
}