variable "identifier" {
  type = string
}

variable "region" {
  type = string
}

variable "network_cidr" {
  type = string
}

variable "use_existing_vpc" {}

variable "vpc_network" {}

variable "control_name" {}

variable "target_tags" {
  default = []
  type    = list(any)
}

variable "ingress_cidr" {
  type = string
}

variable "bastion_create" {
  type = bool
}
