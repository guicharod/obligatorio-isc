# Llama al módulo de red y le pasa los valores
module "network" {
  source = "./modules/network"

  nombreproyecto = var.nombreproyecto
  vpc_cidr       = var.vpc_cidr
  az_a           = var.az_a
  az_b           = var.az_b
  cidr_public_a  = var.cidr_public_a
  cidr_public_b  = var.cidr_public_b
  cidr_app_a     = var.cidr_app_a
  cidr_app_b     = var.cidr_app_b
  cidr_db_a      = var.cidr_db_a
  cidr_db_b      = var.cidr_db_b
}