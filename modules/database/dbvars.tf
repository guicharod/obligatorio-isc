variable "nombreproyecto" {
  type = string
}

# Subredes de datos donde vive la bd
variable "sn_db_a_id" {
  type = string
}

variable "sn_db_b_id" {
  type = string
}

# Security group de la bd
variable "sg_db_id" {
  type = string
}

# Tamaño de la instancia de bd de datos
variable "db_instance_class" {
  type = string
}

# Nombre de la base que se crea al inicio
variable "db_nombre" {
  type = string
}

# Usuario administrador
variable "db_usuario" {
  type = string
}

# Contraseña del administrador (sensitive)
variable "db_password" {
  type      = string
  sensitive = true
}

# true: no guarda snapshot al hacer destroy (para desarrollo)
variable "db_skip_final_snapshot" {
  type = bool
}