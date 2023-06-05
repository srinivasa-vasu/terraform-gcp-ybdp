# services inputs
variable "control_name" {
  description = "name of the replicated instance"
  type        = string
  default     = "replicated"
}

variable "bastion_on" {
  description = "flag to determine new bastion host creation"
  default     = true
  type        = bool
}

#variable "machine_image" {
#  description = "name of the machine image to create the instance from"
#  type        = string
#}

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

variable "host_key" {
  description = "hostname private key to upload to the replicated instance"
  type        = string
}

variable "host_cert" {
  description = "hostname cert to upload to the replicated instance"
  type        = string
}

variable "license_key" {
  description = "license key to activate the yugabyte platform"
  type        = string
  default     = null
}

variable "replicated_license_key" {
  description = "license key to activate the yugabyte platform"
  type        = string
}

variable "installer_license_key" {
  description = "license key to activate the yugabyte platform"
  type        = string
}

variable "hostname" {
  description = "hostname without the domain name"
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
  default     = "50"
  type        = string
}

# vpc inputs
variable "vpc_on" {
  description = "flag to determine new VPC creation"
  default     = false
}

variable "vpc_network" {
  description = "network name to provision the services to"
  default     = "default"
  type        = string
}

variable "control_network_cidr" {
  type        = string
  description = "cidr for a fresh vpc network subnet"
  default     = "10.160.2.0/27"
}

variable "universe_network_cidr" {
  type        = string
  description = "cidr for a fresh vpc network subnet"
  default     = "10.160.3.0/24"
}

variable "network_cidr" {
  type        = string
  description = "cidr for a fresh vpc network subnet"
  default     = "10.160.4.0/24"
}

# cloud inputs
variable "project" {
  description = "gcp project name"
  type        = string
}

variable "region" {
  description = "gcp region to deploy the services to"
  default     = "asia-south1"
  type        = string
}

variable "additional_regions" {
  description = "additional gcp regions to create in the vpc"
  type        = list(any)
  default     = []
}

variable "additional_regions_cidr" {
  description = "additional gcp regions to create in the vpc"
  type        = list(any)
  default     = ["10.160.5.0/24", "10.160.6.0/24", "10.160.7.0/24", "10.160.8.0/24"]
}

variable "credentials" {
  description = "iam credentials"
  type        = string
}

# run unique identifier
variable "identifier" {
  description = "identifier to prefix to all resources created"
  default     = "yugabyte"
  type        = string
}

variable "domain" {
  description = "domain name to provision"
  type        = string
}

variable "dns_on" {
  description = "flag to determine new dns creation"
  default     = false
  type        = bool
}

variable "zone" {
  description = "zone name of the existing/new one"
  type        = string
}

variable "universe_tag" {
  description = "target tag for the universe instances"
  type        = string
  default     = "cluster-server"
}

variable "ha_on" {
  description = "flag to determine backup platform instance"
  default     = false
  type        = bool
}

variable "public_on" {
  description = "flag to determine default allow-all port access to the client ip"
  default     = false
  type        = bool
}

variable "img_name" {
  description = "os image name"
  type        = string
}

variable "img_project" {
  description = "os image cloud project"
  type        = string
}

variable "airgap" {
  description = "flag to determine if the installation is airgapped"
  type        = bool
  default     = false
}

variable "instance_labels" {
  description = "labels to be added to the instance(s)"
  type        = map(string)
  default     = {}
}

variable "replicated" {
  description = "flag to determine if replicated based workflow should be used"
  type        = bool
  default     = true
}

variable "installer" {
  description = "flag to determine if installer based workflow should be used"
  type        = bool
  default     = false
}
