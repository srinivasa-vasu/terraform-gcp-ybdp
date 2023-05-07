variable "identifier" {
  type = string
}

variable "local_identifier" {
  type    = string
  default = "fw"
}

variable "vpc_nw" {
  type = string
}

variable "bastion_on" {
  type = bool
}

variable "public_on" {
  type = bool
}

variable "target_tags" {
  default = []
  type    = list(any)
}

variable "control_subnet_cidr" {
  type        = string
  description = "replicated and bastion instances will be provisioned in this subnet"
}

variable "universe_subnet_cidr" {
  type        = string
  description = "universe instances will be provisioned in this subnet"
}

variable "ingress_cidr" {
  type = string
}

variable "airgap" {
  description = "flag to determine if the installation is airgapped"
  type        = bool
}
