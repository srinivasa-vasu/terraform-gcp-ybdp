variable "identifier" {
  type = string
}

variable "local_identifier" {
  type    = string
  default = "lb"
}

variable "vpc_network" {
  type = string
}

variable "health_check" {
  type = bool
}

variable "ports_forward" {
  type = list(any)
}

variable "ports" {
  type    = list(any)
  default = []
}

variable "instance" {
  type = string
}

variable "health_check_port" {
  default = 8800
}

variable "health_check_interval" {
  default = 10
}

variable "health_check_timeout" {
  default = 3
}

variable "health_check_healthy_threshold" {
  default = 6
}

variable "health_check_unhealthy_threshold" {
  default = 3
}

variable "target_tags" {
  default = []
  type    = list(any)
}

variable "ingress_cidr" {
  type = string
}
