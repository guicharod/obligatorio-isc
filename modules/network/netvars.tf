variable "nombreproyecto" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "az_a" {
  type = string
}

variable "az_b" {
  type = string
}

variable "cidr_public_a" {
  type = string
}

variable "cidr_public_b" {
  type = string
}

variable "cidr_app_a" {
  type = string
}

variable "cidr_app_b" {
  type = string
}

# Rangos de las subredes de datos
variable "cidr_db_a" {
  type = string
}

variable "cidr_db_b" {
  type = string
}