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
  tag     = "${var.identifier}-${var.control_name}"
  ingress = "${chomp(data.http.localip.body)}/32"
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

# VPC network and compute forewall related resources
module "network" {
  source               = "./modules/network"
  identifier           = var.identifier
  region               = var.region
  control_subnet_cidr  = var.control_network_cidr
  universe_subnet_cidr = var.universe_network_cidr
  vpc_network          = var.vpc_network
  vpc_on               = var.vpc_on
  control_name         = var.control_name
  target_tags          = ["${local.tag}"]
  ingress_cidr         = local.ingress
  bastion_on           = var.bastion_on
}

# Load balancer and related firewall resources
module "lb" {
  source        = "./modules/lb"
  identifier    = var.identifier
  vpc_network   = module.network.network
  ports         = ["443", "8800"]
  ports_forward = ["443", "8800"]
  target_tags   = ["${local.tag}"]
  instances     = module.compute.instance
  health_check  = true
  ingress_cidr  = local.ingress
}

# DNS zone related resources
module "dns" {
  source     = "./modules/dns"
  dns_on     = var.dns_on
  identifier = var.identifier
  domain     = var.domain
  dns_to_ip  = module.lb.address
  hostname   = var.hostname
  zone       = var.zone
}

# replicate and bastion compute related resources
module "compute" {
  source               = "./modules/compute"
  identifier           = var.identifier
  instance_count       = var.replicated_instance_count
  node_type            = var.node_type
  node_img             = data.google_compute_image.instance_image.self_link
  disk_size            = var.disk_size
  bastion_on           = var.bastion_on
  bastion_node_type    = var.bastion_node_type
  bastion_disk_size    = var.bastion_disk_size
  zones                = data.google_compute_zones.available.names
  vpc_nw               = module.network.network
  vpc_nw_subnet        = module.network.control_subnet
  ingress_cidr         = local.ingress
  ssh_user             = var.ssh_user
  ssh_public_key       = var.ssh_public_key
  ssh_private_key      = var.ssh_private_key
  replicated_host_cert = var.replicated_host_cert
  replicated_host_key  = var.replicated_host_key
  license_key          = var.license_key
  hostname             = "${var.hostname}.${var.domain}"
  target_tags          = ["${local.tag}"]
}
