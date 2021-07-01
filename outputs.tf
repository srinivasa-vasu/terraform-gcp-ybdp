output "ssh_user" {
  sensitive = true
  value     = var.ssh_user
}

output "ssh_key" {
  sensitive = true
  value     = var.ssh_private_key
}

output "replicated_instance" {
  value = "https://${module.lb.address}:8800"
}

output "bastion_instance" {
  value = join(" ", ["ssh -i <private_key>", "${one(google_compute_address.bastion_ip.*.address)}"])
}

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

output "lb_name" {
  value = module.lb.name
}

output "lb_address" {
  value = module.lb.address
}
