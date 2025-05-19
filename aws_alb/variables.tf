variable "security_group_ids" {
  default = ["sg-0ed111111111f34f"]
  type    = list(string)
}

variable "subnet_ids" {
  default = ["subnet-00000000", "subnet-000000000000"]
  type    = list(string)
}

variable "siemens_dev_inst" {
  type    = string
  default = "i-0a2d0ec11111111114"
}

variable "siemens_prod_inst" {
  type    = string
  default = "i-04f901111111123986"

}

variable "vpc" {
  type    = string
  default = "vpc-41111111e"
}