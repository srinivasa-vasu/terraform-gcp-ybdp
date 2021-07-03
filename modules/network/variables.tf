variable "identifier" {
  type = string
}

variable "region" {
  type = string
}

variable "control_subnet_cidr" {
  type = string
  description = "replicated and bastion instances will be provisioned in this subnet"
}

variable "universe_subnet_cidr" {
  type = string
  description = "universe instances will be provisioned in this subnet"
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
