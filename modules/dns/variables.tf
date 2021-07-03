variable "identifier" {
  type = string
}

variable "local_identifier" {
  type    = string
  default = "zone"
}

variable "domain" {
  type = string
}

variable "dns_on" {
  type = bool
}

variable "dns_to_ip" {
  type = string
}

variable "hostname" {
  description = "hostname without the domain name"
  type        = string
}

variable "zone" {
  description = "zone name of the existing/new one"
  type        = string
}
