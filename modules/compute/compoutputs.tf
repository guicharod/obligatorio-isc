# IP pública del bastion
output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

# DNS del load balancer
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}