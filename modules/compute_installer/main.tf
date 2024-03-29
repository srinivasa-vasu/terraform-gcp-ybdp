locals {
  name         = "${var.identifier}-${var.local_identifier}"
  bastion_name = "${var.identifier}-bastion"
  yba_base_url = "https://downloads.yugabyte.com/releases"

  yba_image_list = [
    {
      "version" = "2.20"
      "path"    = "${local.yba_base_url}/2.20.0.0/yba_installer_full-2.20.0.0-b76-linux-x86_64.tar.gz"
    },
    {
      "version" = "2.18"
      "path"    = "${local.yba_base_url}/2.18.4.0/yba_installer_full-2.18.4.0-b52-linux-x86_64.tar.gz"
    },
    {
      "version" = "2.19"
      "path"    = "${local.yba_base_url}/2.19.2.0/yba_installer_full-2.19.2.0-b121-linux-x86_64.tar.gz"
    }
  ]
  yba_selected_image = lookup({ for val in local.yba_image_list :
  0 => val if val.version == var.yba_image_version }, 0, local.yba_image_list[0])

  image_list = [
    {
      "type" = "almalinux8"
      "path" = "almalinux-cloud/almalinux-8"
      "cmd"  = "yum"
    },
    {
      "type" = "ubuntu18"
      "path" = "ubuntu-os-cloud/ubuntu-1804-lts"
      "cmd"  = "apt-get"
    },
    {
      "type" = "ubuntu20"
      "path" = "ubuntu-os-cloud/ubuntu-2004-lts"
      "cmd"  = "apt-get"
    },
    {
      "type" = "ubuntu22"
      "path" = "ubuntu-os-cloud/ubuntu-2204-lts"
      "cmd"  = "apt-get"
    },
    {
      "type" = "centos7"
      "path" = "centos-cloud/centos-7"
      "cmd"  = "yum"
    },
    {
      "type" = "almalinux9"
      "path" = "almalinux-cloud/almalinux-9"
      "cmd"  = "yum"
    },
    {
      "type" = "rhel8"
      "path" = "rhel-cloud/rhel-8"
      "cmd"  = "yum"
    },
    {
      "type" = "rhel9"
      "path" = "rhel-cloud/rhel-9"
      "cmd"  = "yum"
    },
    {
      "type" = "cos"
      "path" = "cos-cloud/cos-stable"
      "cmd"  = "yum"
    }
  ]
  selected_image = lookup({ for val in local.image_list :
  0 => val if val.type == var.image_type }, 0, local.image_list[0])

  bastion_selected_image = lookup({ for val in local.image_list :
  0 => val if val.type == var.bastion_image_type }, 0, local.image_list[0])
}

data "local_file" "secure_cert" {
  filename = var.host_cert
}

data "template_file" "installer_configure" {
  template = file("scripts/installer.tpl")

  vars = {
    download_path       = local.yba_selected_image.path
    user_home           = "/home/${var.ssh_user}"
    e_user_home         = replace("/home/${var.ssh_user}", "/", "\\/")
    default_config_path = "/opt/yba-ctl/yba-ctl.yml"
    password            = random_password.password.result
    cmd                 = local.selected_image.cmd
  }
}

resource "random_password" "password" {
  length           = 40
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "_=-@%"
}

# yba instance resource; can have more than 1 instance for HA; set `installer_instance_count` variable
# appropriately
resource "google_compute_instance" "instance" {
  count        = var.instance_count
  name         = "${local.name}-n${format("%d", count.index + 1)}"
  machine_type = var.node_type
  zone         = element(var.zones, count.index)
  tags         = concat(var.target_tags, [format("node-%d", count.index + 1)])

  boot_disk {
    initialize_params {
      image  = local.selected_image.path
      size   = var.disk_size
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
      image  = local.bastion_selected_image.path
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

resource "null_resource" "post_create_bastion_on_install" {
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
    source      = var.host_key
    destination = "/home/${var.ssh_user}/domain.pem"
  }
  provisioner "file" {
    source      = var.host_cert
    destination = "/home/${var.ssh_user}/domain.crt"
  }
  provisioner "file" {
    source      = var.license_key
    destination = "/home/${var.ssh_user}/license_key"
  }
  provisioner "remote-exec" {
    inline = [
      data.template_file.installer_configure.rendered
    ]
  }
}

resource "null_resource" "post_create_bastion_off_install" {
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
    source      = var.host_key
    destination = "/home/${var.ssh_user}/domain.pem"
  }
  provisioner "file" {
    source      = var.host_cert
    destination = "/home/${var.ssh_user}/domain.crt"
  }
  provisioner "file" {
    source      = var.license_key
    destination = "/home/${var.ssh_user}/license_key"
  }
  provisioner "remote-exec" {
    inline = [
      data.template_file.installer_configure.rendered
    ]
  }
}

resource "google_compute_address" "bastion_ip" {
  name  = local.bastion_name
  count = var.bastion_on ? 1 : 0
}
