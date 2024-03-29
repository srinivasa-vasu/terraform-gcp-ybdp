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
  ingress = "${chomp(data.http.localip.response_body)}/32"
  ports   = var.replicated ? ["443", "8800", "9090"] : ["443", "9090"]
}

data "google_compute_zones" "available" {
  region = var.region
}

# Workstation public ip to allow access to. It identies the IP where this gets executed and adds it to the
# firewall rule in the firewall block
data "http" "localip" {
  url = "https://ipv4.icanhazip.com"
  # url = "http://checkip.amazonaws.com"
}

# data "google_compute_image" "instance_image" {
#   # family  = "ubuntu-1804-lts"
#   name    = var.img_name
#   project = var.img_project
# }

# VPC network and compute forewall related resources
module "network" {
  source                          = "./modules/network"
  identifier                      = var.identifier
  region                          = var.region
  additional_regions              = var.vpc_on ? var.additional_regions : list("")
  control_subnet_cidr             = var.control_network_cidr
  universe_subnet_cidr            = var.universe_network_cidr
  additional_universe_subnet_cidr = var.vpc_on ? var.additional_regions_cidr : list("")
  vpc_network                     = var.vpc_network
  vpc_on                          = var.vpc_on
  control_name                    = var.control_name
  ingress_cidr                    = local.ingress
  target_tags                     = ["${local.tag}", "${var.universe_tag}"]
}

# Load balancer and related firewall resources
module "lb" {
  # for_each      = module.compute.instances
  # for_each = {
  #   for ic in range(var.replicated_instance_count) : ic => ic
  # }
  source            = "./modules/lb"
  identifier        = "${var.identifier}-main"
  vpc_network       = module.network.network
  ports             = local.ports
  ports_forward     = local.ports
  target_tags       = ["${local.tag}", "node-1"]
  instance          = var.replicated ? module.compute_replicated[0].instances[0].self_link : module.compute_installer[0].instances[0].self_link
  health_check      = true
  health_check_port = var.replicated ? 8800 : 443
  ingress_cidr      = local.ingress
}

module "lb_ha" {
  source            = "./modules/lb"
  identifier        = "${var.identifier}-fb"
  vpc_network       = module.network.network
  ports             = local.ports
  ports_forward     = local.ports
  target_tags       = ["${local.tag}", "node-2"]
  instance          = var.replicated ? module.compute_replicated[0].instances[1].self_link : module.compute_installer[0].instances[1].self_link
  health_check      = true
  health_check_port = var.replicated ? 8800 : 443
  ingress_cidr      = local.ingress
  count             = var.ha_on ? 1 : 0
}

# DNS zone related resources
module "dns" {
  source      = "./modules/dns"
  dns_on      = var.dns_on
  identifier  = var.identifier
  domain      = var.domain
  ip_to_dns   = var.ha_on ? [module.lb.address, module.lb_ha[0].address] : [module.lb.address]
  hostname    = var.hostname
  zone        = var.zone
  airgap      = var.airgap
  vpc_network = module.network.network
}

# replicate and bastion compute related resources
module "compute_replicated" {
  source             = "./modules/compute_replicated"
  identifier         = var.identifier
  instance_count     = var.ha_on ? 2 : 1
  node_type          = var.node_type
  image_type         = var.image_type
  disk_size          = var.disk_size
  bastion_on         = var.bastion_on
  bastion_node_type  = var.bastion_node_type
  bastion_disk_size  = var.bastion_disk_size
  bastion_image_type = var.bastion_image_type
  zones              = data.google_compute_zones.available.names
  vpc_nw             = module.network.network
  vpc_nw_subnet      = module.network.control_subnet
  ingress_cidr       = local.ingress
  ssh_user           = var.ssh_user
  ssh_public_key     = var.ssh_public_key
  ssh_private_key    = var.ssh_private_key
  host_cert          = var.host_cert
  host_key           = var.host_key
  license_key        = var.replicated ? var.replicated_license_key : var.installer_license_key
  hostname           = "${var.hostname}.${var.domain}"
  target_tags        = ["${local.tag}"]
  instance_labels    = var.instance_labels
  count              = var.replicated ? 1 : 0
}

module "compute_installer" {
  source             = "./modules/compute_installer"
  yba_image_version  = var.yba_image_version
  identifier         = var.identifier
  instance_count     = var.ha_on ? 2 : 1
  node_type          = var.node_type
  image_type         = var.image_type
  disk_size          = var.disk_size
  bastion_on         = var.bastion_on
  bastion_node_type  = var.bastion_node_type
  bastion_disk_size  = var.bastion_disk_size
  bastion_image_type = var.bastion_image_type
  zones              = data.google_compute_zones.available.names
  vpc_nw             = module.network.network
  vpc_nw_subnet      = module.network.control_subnet
  ingress_cidr       = local.ingress
  ssh_user           = var.ssh_user
  ssh_public_key     = var.ssh_public_key
  ssh_private_key    = var.ssh_private_key
  host_cert          = var.host_cert
  host_key           = var.host_key
  license_key        = var.replicated ? var.replicated_license_key : var.installer_license_key
  hostname           = "${var.hostname}.${var.domain}"
  target_tags        = ["${local.tag}"]
  instance_labels    = var.instance_labels
  count              = var.installer ? 1 : 0
}

# firewall related resources; creates all rules but airgap
module "firewall" {
  source                          = "./modules/firewall"
  identifier                      = var.identifier
  vpc_nw                          = module.network.network
  target_tags                     = ["${local.tag}", "${var.universe_tag}"]
  control_subnet_cidr             = var.control_network_cidr
  universe_subnet_cidr            = var.universe_network_cidr
  additional_universe_subnet_cidr = var.vpc_on ? var.additional_regions_cidr : list("")
  ingress_cidr                    = local.ingress
  bastion_on                      = var.bastion_on
  public_on                       = var.public_on
  init                            = true
}

# firewall related resources; creates airgap rules
module "firewall_ag" {
  source                          = "./modules/firewall"
  identifier                      = var.identifier
  vpc_nw                          = module.network.network
  target_tags                     = ["${local.tag}", "${var.universe_tag}"]
  control_subnet_cidr             = var.control_network_cidr
  universe_subnet_cidr            = var.universe_network_cidr
  additional_universe_subnet_cidr = var.vpc_on ? var.additional_regions_cidr : list("")
  ingress_cidr                    = local.ingress
  airgap                          = var.airgap
  depends_on                      = [module.compute_replicated, module.compute_installer]
}
