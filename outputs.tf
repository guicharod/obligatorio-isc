# IP del bastion
output "ip_bastion" {
  value = module.compute.bastion_ip
}

# URL del sitio
output "url_sitio" {
  value = "http://${module.compute.alb_dns_name}"
}