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
  ingress_cidr         = local.ingress
  target_tags          = ["${local.tag}", "${var.universe_tag}"]
  bastion_on           = var.bastion_on
}

# Load balancer and related firewall resources
module "lb" {
  # for_each      = module.compute.instances
  # for_each = {
  #   for ic in range(var.replicated_instance_count) : ic => ic
  # }
  source        = "./modules/lb"
  identifier    = "${var.identifier}-main"
  vpc_network   = module.network.network
  ports         = ["443", "8800"]
  ports_forward = ["443", "8800"]
  target_tags   = ["${local.tag}", "node-1"]
  instance      = module.compute.instances[0].self_link
  health_check  = true
  ingress_cidr  = local.ingress
}

module "fb_lb" {
  source        = "./modules/lb"
  identifier    = "${var.identifier}-fb"
  vpc_network   = module.network.network
  ports         = ["443", "8800"]
  ports_forward = ["443", "8800"]
  target_tags   = ["${local.tag}", "node-2"]
  instance      = module.compute.instances[1].self_link
  health_check  = true
  ingress_cidr  = local.ingress
  count         = var.ha_on ? 1 : 0
}

# DNS zone related resources
module "dns" {
  source     = "./modules/dns"
  dns_on     = var.dns_on
  identifier = var.identifier
  domain     = var.domain
  ip_to_dns  = var.ha_on ? [module.lb.address, module.fb_lb[0].address] : [module.lb.address]
  hostname   = var.hostname
  zone       = var.zone
}

# replicate and bastion compute related resources
module "compute" {
  source               = "./modules/compute"
  identifier           = var.identifier
  instance_count       = var.ha_on ? 2 : 1
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
