variable "ingress_ports" {
  type    = list(any)
  default = [22, 80]
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}