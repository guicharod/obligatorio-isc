variable "nombreproyecto" {
  type = string
}

# Región donde se muestran las métricas del dashboard
variable "region" {
  type = string
}

# Mail que recibe las alertas
variable "email_alertas" {
  type = string
}

# Identificadores de los recursos a monitorear
variable "alb_arn_suffix" {
  type = string
}

variable "tg_arn_suffix" {
  type = string
}

variable "asg_name" {
  type = string
}

variable "db_identifier" {
  type = string
}