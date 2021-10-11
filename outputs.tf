# ssh related info
output "ssh_user" {
  sensitive = true
  value     = var.ssh_user
}

output "ssh_key" {
  sensitive = true
  value     = var.ssh_private_key
}

# instance related
output "main_replicated_instance" {
  value = "https://${module.lb.address}:8800"
}

output "fallback_replicated_instance" {
  value = var.ha_on ? "https://${module.fb_lb[0].address}:8800" : "NA"
}

output "bastion_instance" {
  value = module.compute.bastion_instance
}

output "replicated_instances" {
  value = module.compute.replicated_instances
}

output "console_password" {
  sensitive = true
  value     = module.compute.console_password
}

# vpc related
output "target_universe_tag" {
  value = var.universe_tag
}

output "network" {
  value = module.network.network
}

output "network_name" {
  value = module.network.network_name
}

# yugaware management network details
output "control_subnet" {
  value = module.network.control_subnet
}

output "control_subnet_cidr_range" {
  value = module.network.control_subnet_cidr_range
}

output "control_subnet_name" {
  value = module.network.control_subnet_name
}

# yugaware universe network details
output "universe_subnet" {
  value = module.network.universe_subnet
}

output "universe_subnet_cidr_range" {
  value = module.network.universe_subnet_cidr_range
}

output "universe_subnet_name" {
  value = module.network.universe_subnet_name
}

# lb related
output "main_lb_name" {
  value = module.lb.name
}

output "main_lb_address" {
  value = module.lb.address
}

output "fallback_lb_name" {
  value = var.ha_on ? module.fb_lb[0].name : "NA"
}

output "fallback_lb_address" {
  value = var.ha_on ? module.fb_lb[0].address : "NA"
}

# dns related
output "domain_name" {
  value = module.dns.domain_name
}

output "hosted_zone" {
  value = module.dns.hosted_zone
}

output "main_replicated_console_dns" {
  value = module.dns.main_replicated_console_dns
}

output "fallback_replicated_console_dns" {
  value = module.dns.fb_replicated_console_dns
}
