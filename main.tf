# terraform {
#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "3.5.0"
#     }
#   }
# }

provider "google" {
  project     = var.project
  region      = var.region
  credentials = file(var.credentials)
}

provider "google-beta" {
  project     = var.project
  region      = var.region
  credentials = file(var.credentials)
}

locals {
  tag = "${var.identifier}-${var.control_name}"
}

data "google_compute_zones" "available" {
  region = var.region
}

# Workstation public ip to allow access to. It identies the IP where this executed and adds it to the 
# firewall rule in the firewall block
data "http" "localip" {
  url = "http://ipv4.icanhazip.com"
}

data "google_compute_image" "instance_image" {
  family  = "ubuntu-1804-lts"
  project = "ubuntu-os-cloud"
}

# resource "google_service_account" "sa" {
#   account_id   = local.tag
#   display_name = "Replicated SA"
# }

# resource "google_compute_instance_from_machine_image" "replicated_instance" {
#   provider             = google-beta
#   count                = var.replicated_instance_count
#   name                 = "${var.identifier}-replicated-n${format("%d", count.index + 1)}"
#   machine_type         = var.node_type
#   zone                 = element(data.google_compute_zones.available.names, count.index)
#   tags                 = ["${local.tag}"]
#   source_machine_image = "projects/${var.project}/global/machineImages/${var.machine_image}"

#   network_interface {
#     network    = module.network.network
#     subnetwork = module.network.subnet
#   }

#   service_account {
#     email  = google_service_account.sa.email
#     scopes = ["cloud-platform"]
#   }
# }

# Replicated instance resource; can have more than 1 instance for HA; set `replicated_instance_count` variable
# appropriately 
resource "google_compute_instance" "replicated_instance" {
  count        = var.replicated_instance_count
  name         = "${var.identifier}-replicated-n${format("%d", count.index + 1)}"
  machine_type = var.node_type
  zone         = element(data.google_compute_zones.available.names, count.index)
  tags         = ["${local.tag}"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.instance_image.self_link
      size  = var.disk_size
    }
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }

  # Run the script once during the first start-up. Upgrade to this would happen in a controlled fashion
  metadata_startup_script = "[[ ! -f ~/init-replicated.completed ]] && (curl -sSL https://get.replicated.com/docker && touch ~/init-replicated.completed) | sudo bash"

  network_interface {
    network    = module.network.network
    subnetwork = module.network.subnet
  }

}

resource "google_compute_address" "bastion_ip" {
  name  = "${var.identifier}-bastion-ip"
  count = var.bastion_on ? 1 : 0
}

# Bastion instance to connect to the platform network. Platform network is internal. To ssh to the replicated machine
# set `bastion_on` to true to get a bastion instance to connect to the platform network
resource "google_compute_instance" "bastion_instance" {
  count        = var.bastion_on ? 1 : 0
  name         = "${var.identifier}-bastion"
  machine_type = var.bastion_node_type
  zone         = element(data.google_compute_zones.available.names, count.index)
  tags         = ["${var.identifier}-bastion"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.instance_image.self_link
      size  = var.bastion_disk_size
    }
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }

  network_interface {
    network    = module.network.network
    subnetwork = module.network.subnet
    access_config {
      nat_ip = google_compute_address.bastion_ip[count.index].address
    }
  }

}

# VPC network related resources
module "network" {
  source       = "./modules/network"
  identifier   = var.identifier
  region       = var.region
  network_cidr = var.network_cidr
  vpc_network  = var.vpc_network
  vpc_on       = var.vpc_on
  control_name = var.control_name
  target_tags  = ["${local.tag}"]
  ingress_cidr = "${chomp(data.http.localip.body)}/32"
  bastion_on   = var.bastion_on
}

# Load balancer related resources
module "lb" {
  source        = "./modules/lb"
  identifier    = var.identifier
  vpc_network   = module.network.network
  ports         = ["443", "8800"]
  ports_forward = ["443", "8800"]
  target_tags   = ["${local.tag}"]
  instances     = google_compute_instance.replicated_instance.*.self_link
  health_check  = true
  ingress_cidr  = "${chomp(data.http.localip.body)}/32"
}

# DNS zone related resources
module "dns" {
  source     = "./modules/dns"
  identifier = var.identifier
  domain     = var.domain
  dns_on     = var.dns_on
  dns_to_ip  = module.lb.address
}
