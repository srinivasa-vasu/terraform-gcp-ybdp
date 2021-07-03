output "network" {
  value = data.google_compute_network.vpc_state.self_link
}

output "network_name" {
  value = data.google_compute_network.vpc_state.name
}

output "control_subnet" {
  value = element(concat(google_compute_subnetwork.control_subnet.*.self_link, tolist([""])), 0)
}

output "control_subnet_cidr_range" {
  value = element(concat(google_compute_subnetwork.control_subnet.*.ip_cidr_range, tolist([""])), 0)
}

output "control_subnet_name" {
  value = element(concat(google_compute_subnetwork.control_subnet.*.name, tolist([""])), 0)
}

output "universe_subnet" {
  value = element(concat(google_compute_subnetwork.universe_subnet.*.self_link, tolist([""])), 0)
}

output "universe_subnet_cidr_range" {
  value = element(concat(google_compute_subnetwork.universe_subnet.*.ip_cidr_range, tolist([""])), 0)
}

output "universe_subnet_name" {
  value = element(concat(google_compute_subnetwork.universe_subnet.*.name, tolist([""])), 0)
}
