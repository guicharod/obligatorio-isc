# IP del bastion
output "ip_bastion" {
  value = module.compute.bastion_ip
}

# URL del sitio
output "url_sitio" {
  value = "http://${module.compute.alb_dns_name}"
}

# IPs privadas de los servidores de app, para entrar por el bastion
output "ips_privadas_app" {
  value = module.compute.app_private_ips
}

# Endpoint de la base de datos
output "db_endpoint" {
  value = module.database.db_endpoint
}