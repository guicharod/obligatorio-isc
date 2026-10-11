# Datos de la red que usan los otros módulos

output "vpc_id" {
  value = aws_vpc.aws_vpc.id
}

output "sn_public_a_id" {
  value = aws_subnet.sn-public-a.id
}

output "sn_public_b_id" {
  value = aws_subnet.sn-public-b.id
}

output "sn_app_a_id" {
  value = aws_subnet.sn-app-a.id
}

output "sn_app_b_id" {
  value = aws_subnet.sn-app-b.id
}

output "sn_db_a_id" {
  value = aws_subnet.sn-db-a.id
}

output "sn_db_b_id" {
  value = aws_subnet.sn-db-b.id
}