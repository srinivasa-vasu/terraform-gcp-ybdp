output "instances" {
  value = google_compute_instance.instance.*
}

output "installer_instances" {
  value = {
    for instance in google_compute_instance.instance :
    instance.id => {
      "private_ip" = instance.network_interface.0.network_ip,
    }
  }
}

output "bastion_instance" {
  value = var.bastion_on ? join(" ", ["ssh -i <private_key>", "${one(google_compute_address.bastion_ip.*.address)}"]) : "NA"
}

output "password" {
  sensitive = true
  value     = random_password.password.result
}
