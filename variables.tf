# User Variables
variable "region" {
  default = "EU-East-1"
}

variable "image" {
  default = "Ubuntu 16.04 64bit"
}

variable "project_name" {
  default = "OpenFaaSProject1"
}

variable "team_id" {
  default = "11682"
}

variable "plan_id" {
  default = "161"
}

variable "private_key" {
  default = "~/.ssh/id_rsa"
}

variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}

