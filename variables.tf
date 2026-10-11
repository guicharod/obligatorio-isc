# ---------------------------------------------------------------
# modules/network
# ---------------------------------------------------------------

variable "nombreproyecto" {
  type    = string
  default = "obligatorio-isc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az_a" {
  type    = string
  default = "us-east-1a"
}

variable "az_b" {
  type    = string
  default = "us-east-1b"
}

variable "cidr_public_a" {
  type    = string
  default = "10.0.0.0/24"
}

variable "cidr_public_b" {
  type    = string
  default = "10.0.1.0/24"
}

# Subredes de aplicación
variable "cidr_app_a" {
  type    = string
  default = "10.0.10.0/24"
}

variable "cidr_app_b" {
  type    = string
  default = "10.0.11.0/24"
}

# Subredes de datos
variable "cidr_db_a" {
  type    = string
  default = "10.0.20.0/24"
}

variable "cidr_db_b" {
  type    = string
  default = "10.0.21.0/24"
}

# ---------------------------------------------------------------
# modules/security
# ---------------------------------------------------------------

# IP pública desde donde se va a administrar.
variable "ip_admin" {
  type = string
}

variable "puerto_app" {
  type    = number
  default = 80
}

variable "puerto_db" {
  type    = number
  default = 3306
}