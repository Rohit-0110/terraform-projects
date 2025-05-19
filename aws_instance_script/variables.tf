variable "ami" {
  default = "ami-06178cf087598769c"
}

variable "region" {
  default = "eu-west-2"
}

variable "instance_type" {
  default = "m5.large"
}

variable "department" {
  type    = string
  default = "dev"
}

variable "purpose" {
  type    = string
  default = "staging"

}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}