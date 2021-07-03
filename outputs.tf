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
output "replicated_instance" {
  value = "https://${module.lb.address}:8800"
}

output "bastion_instance" {
  value = module.compute.bastion_instance
}

output "console_password" {
  sensitive = true
  value = module.compute.console_password
}

# vpc related
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
output "lb_name" {
  value = module.lb.name
}

output "lb_address" {
  value = module.lb.address
}

# dns related
output "domain_name" {
  value = module.dns.domain_name
}

output "hosted_zone" {
  value = module.dns.hosted_zone
}

output "replicated_console_dns" {
  value = module.dns.replicated_console_dns
}
