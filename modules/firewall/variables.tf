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
  type    = bool
  default = false
}

variable "public_on" {
  type    = bool
  default = false
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
  default     = false
}

variable "init" {
  description = "flag to determine if the default firewall rules should be created"
  type        = bool
  default     = false
}

variable "additional_universe_subnet_cidr" {
  description = "cross region universe firewall cidrs"
  type        = list(any)
}
