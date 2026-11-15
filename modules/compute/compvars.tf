variable "nombreproyecto" {
  type = string
}

variable "vpc_id" {
  type = string
}

# Subredes privadas donde corren los servidores de app
variable "sn_app_a_id" {
  type = string
}

variable "sn_app_b_id" {
  type = string
}

# Subredes públicas: load balancer y bastion
variable "sn_public_a_id" {
  type = string
}

variable "sn_public_b_id" {
  type = string
}

# Security groups de los servidores y del bastion
variable "sg_app_id" {
  type = string
}

variable "sg_bastion_id" {
  type = string
}

# Security group del load balancer
variable "sg_alb_id" {
  type = string
}

# Puerto donde escucha la aplicación
variable "puerto_app" {
  type = number
}

# Tamaño de las instancias
variable "instance_type" {
  type = string
}

# Key pair para SSH (vockey)
variable "key_name" {
  type = string
}

# Cantidad de servidores minimos, deseados y maximos del ASG
variable "asg_min" {
  type = number
}

variable "asg_deseado" {
  type = number
}

variable "asg_max" {
  type = number
}

# Datos de la base que usa la aplicación
variable "db_endpoint" {
  type = string
}

variable "db_nombre" {
  type = string
}

variable "db_usuario" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

# Repositorio y rama de donde se descarga la aplicación
variable "app_repo_url" {
  type = string
}

variable "app_branch" {
  type = string
}