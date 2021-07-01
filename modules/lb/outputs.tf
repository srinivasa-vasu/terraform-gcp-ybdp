output "name" {
  value = google_compute_target_pool.lb.name
}

output "address" {
  value = google_compute_address.lb.address
}
