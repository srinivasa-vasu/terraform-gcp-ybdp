variable "identifier" {
  type = string
}

variable "local_identifier" {
  type    = string
  default = "replicated"
}

variable "instance_count" {
  type = number
}

variable "node_type" {
  description = "type of the node to be used"
  default     = "n1-standard-1"
  type        = string
}

variable "node_img" {
  description = "node image to be used"
  type        = string
}

variable "disk_size" {
  description = "instance diks size"
  default     = "100"
  type        = string
}

variable "bastion_on" {
  type = bool
}

variable "bastion_node_type" {
  description = "type of the node to be used"
  default     = "n1-standard-1"
  type        = string
}

variable "bastion_disk_size" {
  description = "bastion instance diks size"
  default     = "20"
  type        = string
}

variable "zones" {
  type = list(any)
}

variable "vpc_nw" {
  type = string
}

variable "vpc_nw_subnet" {
  type = string
}

variable "ingress_cidr" {
  type = string
}

variable "ssh_private_key" {
  description = "private key to connect to the bastion/replicated instance"
  type        = string
}

variable "ssh_public_key" {
  description = "public key to be use when creating the bastion/replicated instance"
  type        = string
}

variable "ssh_user" {
  description = "user name to connect to bastion/replicated instance"
  type        = string
}

variable "replicated_host_key" {
  description = "hostname private key to upload to the replicated instance"
  type        = string
}

variable "replicated_host_cert" {
  description = "hostname cert to upload to the replicated instance"
  type        = string
}

variable "license_key" {
  description = "license key to activate the yugabyte platform"
  type        = string
}

variable "hostname" {
  description = "platform hostname DNS"
  type        = string
}

variable "target_tags" {
  default = []
  type    = list(any)
}
