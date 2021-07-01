variable "control_name" {
  description = "name of the replicated instance"
  type        = string
  default     = "replicated"
}

variable "replicated_instance_count" {
  description = "the number of replicated instances to create"
  default     = 1
  type        = string
}

variable "bastion_create" {
  description = "bastion host to access the platform network"
  default     = false
  type        = bool
}

variable "machine_image" {
  description = "name of the machine image to create the instance from"
  default     = 1
  type        = string
}

variable "vpc_network" {
  description = "network to provision the services to"
  default     = "default"
  type        = string
}

variable "vpc_firewall" {
  description = "Firewall used by the YugaByte Node"
  default     = "default"
  type        = string
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

variable "node_type" {
  description = "type of the node to be used for replicated instance"
  default     = "e2-standard-4"
  type        = string
}

variable "bastion_node_type" {
  description = "type of the node to be used"
  default     = "n1-standard-1"
  type        = string
}

variable "disk_size" {
  description = "replicated instance diks size"
  default     = "100"
  type        = string
}

variable "bastion_disk_size" {
  description = "bastion instance diks size"
  default     = "20"
  type        = string
}

variable "region" {
  description = "gcp region to deploy the services to"
  default     = "us-west1"
  type        = string
}

variable "identifier" {
  description = "identifier to prefix to all resources created."
  default     = "yugabyte"
  type        = string
}

variable "network_cidr" {
  type        = string
  description = "cidr for fresh vpc network subnet"
  default     = "10.0.4.0/24"
}

variable "use_existing_vpc" {
  description = "flag to determine new VPC creation"
  default     = true
}

variable "project" {
  description = "gcp project name"
  type        = string
}

variable "credentials" {
  description = "iam credentials"
  type        = string
}
