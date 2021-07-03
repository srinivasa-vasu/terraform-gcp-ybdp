locals {
  name         = "${var.identifier}-${var.local_identifier}"
  bastion_name = "${var.identifier}-bastion"
}

# resource "google_service_account" "sa" {
#   account_id   = local.tag
#   display_name = "Replicated SA"
# }

# resource "google_compute_instance_from_machine_image" "replicated_instance" {
#   provider             = google-beta
#   count                = var.replicated_instance_count
#   name                 = "${var.identifier}-replicated-n${format("%d", count.index + 1)}"
#   machine_type         = var.node_type
#   zone                 = element(data.google_compute_zones.available.names, count.index)
#   tags                 = ["${local.tag}"]
#   source_machine_image = "projects/${var.project}/global/machineImages/${var.machine_image}"

#   network_interface {
#     network    = module.network.network
#     subnetwork = module.network.subnet
#   }

#   service_account {
#     email  = google_service_account.sa.email
#     scopes = ["cloud-platform"]
#   }
# }

resource "random_password" "password" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  number           = true
  override_special = "_%@!"
}

# resource "local_file" "special" {
#     content     = "foo!"
#     filename = "${var.license_key}"
# }

# Replicated instance resource; can have more than 1 instance for HA; set `replicated_instance_count` variable
# appropriately 
resource "google_compute_instance" "instance" {
  count        = var.instance_count
  name         = "${local.name}-n${format("%d", count.index + 1)}"
  machine_type = var.node_type
  zone         = element(var.zones, count.index)
  tags         = concat(var.target_tags, [format("node-%d", count.index + 1)])

  boot_disk {
    initialize_params {
      image = var.node_img
      size  = var.disk_size
    }
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }

  # Run the script once during the first start-up. Upgrade to this would happen in a controlled fashion
  # Not a secured way though
  metadata_startup_script = "[[ ! -f ~/init-replicated.completed ]] && (curl -sSL https://get.replicated.com/docker && touch ~/init-replicated.completed) | sudo bash"

  network_interface {
    network    = var.vpc_nw
    subnetwork = var.vpc_nw_subnet
  }

  connection {
    bastion_host        = google_compute_address.bastion_ip[0].address # single bastion
    bastion_private_key = file(var.ssh_private_key)
    bastion_user        = var.ssh_user
    host                = self.network_interface.0.network_ip
    type                = "ssh"
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = var.replicated_host_key
    destination = "/home/${var.ssh_user}/key"
  }
  provisioner "file" {
    source      = var.replicated_host_cert
    destination = "/home/${var.ssh_user}/cert"
  }

  provisioner "file" {
    source      = var.license_key
    destination = "/home/${var.ssh_user}/license"
  }

  provisioner "remote-exec" {
    inline = [
      # update the hostname key and cert
      # wait for ~3+ mins for the replicated instance to be up and running
      "i=1; while [ $i -le 20 ]; do nc -vz localhost 9873 >/dev/null 2>&1; test $? -eq 0 && { replicated console cert set ${var.hostname} ~/key ~/cert; touch ~/cert_upload.completed; break; } || sleep $i; i=$(expr $i + 1); done",
      "test ! -f ~/cert_upload.completed && echo 'Cert upload has failed' || echo 'Cert uploaded successfully'",
      "echo '{\"Password\": {\"Password\": \"${random_password.password.result}\"}}' | replicatedctl console-auth import",
      "replicatedctl license-load < ~/license"
      # "replicatedctl preflight run",
      # "rm ~/key ~/cert ~/license",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      # clean-up job; this has to run irrespective of the other jobs
      "rm ~/key ~/cert ~/license",
      "echo 'Garbage collection done!'"
    ]
  }

}

resource "google_compute_address" "bastion_ip" {
  name  = local.bastion_name
  count = var.bastion_on ? 1 : 0
}

# Bastion instance to connect to the platform network. It's recommended to keep the platform in the internal
# network. To ssh to the replicated machine set `bastion_on` to true to get a bastion instance to connect 
# to the platform network
resource "google_compute_instance" "bastion_instance" {
  count        = var.bastion_on ? 1 : 0
  name         = local.bastion_name
  machine_type = var.bastion_node_type
  zone         = element(var.zones, count.index)
  tags         = ["${local.bastion_name}"]

  boot_disk {
    initialize_params {
      image = var.node_img
      size  = var.bastion_disk_size
    }
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }

  network_interface {
    network    = var.vpc_nw
    subnetwork = var.vpc_nw_subnet
    access_config {
      nat_ip = google_compute_address.bastion_ip[count.index].address
    }
  }

}
