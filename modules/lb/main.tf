locals {
  protocol = "TCP"
  name     = "${var.identifier}-${var.local_identifier}"
}

resource "google_compute_address" "lb" {
  name = "${local.name}-ip"
}

resource "google_compute_forwarding_rule" "lb" {
  name        = "${local.name}-fr-${count.index}"
  ip_address  = google_compute_address.lb.address
  target      = google_compute_target_pool.lb.self_link
  port_range  = element(var.ports_forward, count.index)
  ip_protocol = local.protocol

  count = length(var.ports_forward)
}

resource "google_compute_target_pool" "lb" {
  name          = "${local.name}-tp"
  instances     = var.instances
  health_checks = google_compute_http_health_check.lb.*.name
}

resource "google_compute_http_health_check" "lb" {
  name                = "${local.name}-health-check"
  port                = var.health_check_port
  request_path        = "/status"
  check_interval_sec  = var.health_check_interval
  timeout_sec         = var.health_check_timeout
  healthy_threshold   = var.health_check_healthy_threshold
  unhealthy_threshold = var.health_check_unhealthy_threshold

  count = var.health_check ? 1 : 0
}

resource "google_compute_firewall" "health_check" {
  name    = "${local.name}-health-check"
  network = var.vpc_network
  allow {
    protocol = local.protocol
    ports    = ["${var.health_check_port}"]
  }
  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]
  target_tags   = compact(var.target_tags)

  count = var.health_check ? 1 : 0
}

resource "google_compute_firewall" "lb" {
  name    = "${local.name}-backend"
  network = var.vpc_network
  allow {
    protocol = local.protocol
    ports    = var.ports
  }
  target_tags   = compact(var.target_tags)
  source_ranges = [var.ingress_cidr]

  count = length(var.ports) > 0 ? 1 : 0
}
