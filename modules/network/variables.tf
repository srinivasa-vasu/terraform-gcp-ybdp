variable "identifier" {
  type = string
}

variable "region" {
  type = string
}

variable "additional_regions" {
  description = "additional gcp regions to create in the vpc"
  type        = list(any)
  default     = []
}

variable "control_subnet_cidr" {
  type        = string
  description = "replicated and bastion instances will be provisioned in this subnet"
}

variable "universe_subnet_cidr" {
  type        = string
  description = "universe instances will be provisioned in this subnet"
}

variable "additional_universe_subnet_cidr" {
  description = "cross region universe provisioning"
  type        = list(any)
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

variable "ingress_cidr" {
  type = string
}

variable "bastion_on" {
  type = bool
}

variable "target_tags" {
  description = "target tag for the universe & platform instances"
  type        = list(any)
}

variable "public_on" {
  type = bool
}
