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
  value = var.bastion_on ? join(" ", ["ssh -i <private_key>", "${one(google_compute_address.bastion_ip.*.address)}"]) : "NA"
}

# vpc related
output "network" {
  value = module.network.network
}

output "network_name" {
  value = module.network.network_name
}

output "subnet" {
  value = module.network.subnet
}

output "subnet_cidr_range" {
  value = module.network.subnet_cidr_range
}

output "subnet_gateway" {
  value = module.network.subnet_gateway
}

output "subnet_name" {
  value = module.network.subnet_name
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
