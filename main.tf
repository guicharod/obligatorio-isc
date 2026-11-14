# Llama al módulo de network
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

# Llama al módulo de security
module "security" {
  source = "./modules/security"

  nombreproyecto = var.nombreproyecto
  vpc_id         = module.network.vpc_id # sale del output del módulo de red
  vpc_cidr       = var.vpc_cidr
  ip_admin       = var.ip_admin
  puerto_app     = var.puerto_app
  puerto_db      = var.puerto_db
}

# Llama al módulo de compute
module "compute" {
  source = "./modules/compute"

  nombreproyecto = var.nombreproyecto
  vpc_id         = module.network.vpc_id
  sn_public_a_id = module.network.sn_public_a_id
  sn_public_b_id = module.network.sn_public_b_id
  sn_app_a_id    = module.network.sn_app_a_id
  sn_app_b_id    = module.network.sn_app_b_id
  sg_alb_id      = module.security.sg_alb_id
  sg_app_id      = module.security.sg_app_id
  sg_bastion_id  = module.security.sg_bastion_id
  puerto_app     = var.puerto_app
  instance_type  = var.instance_type
  key_name       = var.key_name
  asg_min        = var.asg_min
  asg_deseado    = var.asg_deseado
  asg_max        = var.asg_max
}

# Llama al módulo de base de datos
module "database" {
  source = "./modules/database"

  nombreproyecto         = var.nombreproyecto
  sn_db_a_id             = module.network.sn_db_a_id
  sn_db_b_id             = module.network.sn_db_b_id
  sg_db_id               = module.security.sg_db_id
  db_instance_class      = var.db_instance_class
  db_nombre              = var.db_nombre
  db_usuario             = var.db_usuario
  db_password            = var.db_password
  db_skip_final_snapshot = var.db_skip_final_snapshot
}