variable "identifier" {
  type = string
}

variable "region" {
  type = string
}

variable "network_cidr" {
  type = string
}

variable "vpc_on" {
  type = bool
}

variable "vpc_network" {
  type = string
}

variable "control_name" {
  type = string
}

variable "target_tags" {
  default = []
  type    = list(any)
}

variable "ingress_cidr" {
  type = string
}

variable "bastion_on" {
  type = bool
}
