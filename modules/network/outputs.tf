output "network" {
  value = data.google_compute_network.vpc_state.self_link
}

output "network_name" {
  value = data.google_compute_network.vpc_state.name
}

output "subnet" {
  value = element(concat(google_compute_subnetwork.subnet.*.self_link, tolist([""])), 0)
}

output "subnet_cidr_range" {
  value = element(concat(google_compute_subnetwork.subnet.*.ip_cidr_range, tolist([""])), 0)
}

output "subnet_gateway" {
  value = element(concat(google_compute_subnetwork.subnet.*.gateway_address, tolist([""])), 0)
}

output "subnet_name" {
  value = element(concat(google_compute_subnetwork.subnet.*.name, tolist([""])), 0)
}
