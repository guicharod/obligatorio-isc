# Nombre DNS de la bd
output "db_endpoint" {
  value = aws_db_instance.db.address
}
# Puerto de la bd
output "db_port" {
  value = aws_db_instance.db.port
}
# Nombre de la instancia RDS (para métricas)
output "db_identifier" {
  value = aws_db_instance.db.identifier
}