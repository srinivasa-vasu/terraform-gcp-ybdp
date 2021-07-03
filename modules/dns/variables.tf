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

variable "ip_to_dns" {
  type = list(any)
}

variable "hostname" {
  description = "hostname without the domain name"
  type        = string
}

variable "zone" {
  description = "zone name of the existing/new one"
  type        = string
}
