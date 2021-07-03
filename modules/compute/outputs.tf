output "instance" {
  value = google_compute_instance.instance.*.self_link
}

output "bastion_instance" {
  value = var.bastion_on ? join(" ", ["ssh -i <private_key>", "${one(google_compute_address.bastion_ip.*.address)}"]) : "NA"
}

output "console_password" {
  sensitive = true
  value = random_password.password.result
}