locals {
  name         = "${var.identifier}-${var.local_identifier}"
  bastion_name = "${var.identifier}-bastion"
}

data "local_file" "secure_cert" {
  filename = var.replicated_host_cert
}

resource "random_password" "password" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "_%@!"
}

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
      image  = var.node_img
      size   = var.disk_size
      labels = var.instance_labels
    }
  }

  labels = var.instance_labels

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
      image  = var.node_img
      size   = var.bastion_disk_size
      labels = var.instance_labels
    }
  }

  labels = var.instance_labels

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

# copy the private key file to connect from bastion to the replicated host
resource "null_resource" "post_create_bastion_on_init" {
  count = var.bastion_on ? 1 : 0
  depends_on = [
    google_compute_instance.bastion_instance
  ]
  connection {
    host        = google_compute_address.bastion_ip[0].address
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
  }
  provisioner "file" {
    source      = var.ssh_private_key
    destination = "/home/${var.ssh_user}/.yb"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/${var.ssh_user}/.yb",
      "echo 'All set!'"
    ]
  }
}

resource "null_resource" "post_create_bastion_on_cert" {
  count = var.bastion_on ? var.instance_count : 0
  depends_on = [
    google_compute_instance.bastion_instance,
    google_compute_instance.instance
  ]

  triggers = {
    cert_change = sensitive(data.local_file.secure_cert.content)
  }

  connection {
    bastion_host        = google_compute_address.bastion_ip[0].address # single bastion
    bastion_private_key = file(var.ssh_private_key)
    bastion_user        = var.ssh_user
    host                = google_compute_instance.instance[count.index].network_interface.0.network_ip
    type                = "ssh"
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = var.replicated_host_key
    destination = "/home/${var.ssh_user}/domain.pem"
  }
  provisioner "file" {
    source      = var.replicated_host_cert
    destination = "/home/${var.ssh_user}/domain.crt"
  }
  provisioner "remote-exec" {
    inline = [
      # update the hostname key and cert
      # wait for ~3+ mins for the replicated instance to be up and running
      # "sudo mv ~/{key,cert} /etc/replicated/",
      "i=1; while [ $i -le 20 ]; do nc -vz localhost 9873 >/dev/null 2>&1; test $? -eq 0 && { sudo mv ~/domain.pem ~/domain.crt /etc/replicated/; replicated console cert set ${var.hostname} /etc/replicated/domain.pem /etc/replicated/domain.crt; touch ~/cert_upload.completed; break; } || sleep $i; i=$(expr $i + 1); done",
      "test ! -f ~/cert_upload.completed && echo 'Cert upload has failed' || echo 'Cert uploaded successfully'"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      # clean-up job; this has to run irrespective of the other jobs
      "rm ~/cert_upload.completed",
      "echo 'Garbage collection done!'"
    ]
  }
}

resource "null_resource" "post_create_bastion_on_auth" {
  count = var.bastion_on ? var.instance_count : 0
  depends_on = [
    null_resource.post_create_bastion_on_cert
  ]

  connection {
    bastion_host        = google_compute_address.bastion_ip[0].address # single bastion
    bastion_private_key = file(var.ssh_private_key)
    bastion_user        = var.ssh_user
    host                = google_compute_instance.instance[count.index].network_interface.0.network_ip
    type                = "ssh"
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = var.license_key
    destination = "/home/${var.ssh_user}/license"
  }
  provisioner "remote-exec" {
    inline = [
      "echo '{\"Password\": {\"Password\": \"${random_password.password.result}\"}}' | replicatedctl console-auth import",
      "replicatedctl license-load < ~/license"
      # "replicatedctl preflight run",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      # clean-up job; this has to run irrespective of the other jobs
      "rm ~/license",
      "echo 'Garbage collection done!'"
    ]
  }
}

resource "null_resource" "post_create_bastion_off_cert" {
  count = var.bastion_on ? 0 : var.instance_count
  depends_on = [
    google_compute_instance.instance
  ]

  triggers = {
    cert_change = sensitive(data.local_file.secure_cert.content)
  }

  connection {
    host        = google_compute_instance.instance[count.index].network_interface.0.network_ip
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = var.replicated_host_key
    destination = "/home/${var.ssh_user}/domain.pem"
  }
  provisioner "file" {
    source      = var.replicated_host_cert
    destination = "/home/${var.ssh_user}/domain.crt"
  }
  provisioner "remote-exec" {
    inline = [
      # update the hostname key and cert
      # wait for ~3+ mins for the replicated instance to be up and running
      "i=1; while [ $i -le 20 ]; do nc -vz localhost 9873 >/dev/null 2>&1; test $? -eq 0 && { sudo mv ~/domain.pem ~/domain.crt /etc/replicated/; replicated console cert set ${var.hostname} /etc/replicated/domain.pem /etc/replicated/domain.crt; touch ~/cert_upload.completed; break; } || sleep $i; i=$(expr $i + 1); done",
      "test ! -f ~/cert_upload.completed && echo 'Cert upload has failed' || echo 'Cert uploaded successfully'"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      # clean-up job; this has to run irrespective of the other jobs
      "rm ~/cert_upload.completed",
      "echo 'Garbage collection done!'"
    ]
  }
}

resource "null_resource" "post_create_bastion_off_auth" {
  count = var.bastion_on ? 0 : var.instance_count
  depends_on = [
    null_resource.post_create_bastion_off_cert
  ]

  connection {
    host        = google_compute_instance.instance[count.index].network_interface.0.network_ip
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = var.license_key
    destination = "/home/${var.ssh_user}/license"
  }
  provisioner "remote-exec" {
    inline = [
      "echo '{\"Password\": {\"Password\": \"${random_password.password.result}\"}}' | replicatedctl console-auth import",
      "replicatedctl license-load < ~/license"
      # "replicatedctl preflight run",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      # clean-up job; this has to run irrespective of the other jobs
      "rm ~/license",
      "echo 'Garbage collection done!'"
    ]
  }
}

resource "google_compute_address" "bastion_ip" {
  name  = local.bastion_name
  count = var.bastion_on ? 1 : 0
}
