# IDs de los security groups para otros módulos.
output "sg_alb_id" {
  value = aws_security_group.sg-alb.id
}

output "sg_bastion_id" {
  value = aws_security_group.sg-bastion.id
}

output "sg_app_id" {
  value = aws_security_group.sg-app.id
}

output "sg_db_id" {
  value = aws_security_group.sg-db.id
}