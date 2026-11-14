# IP pública del bastion
output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

# DNS del load balancer
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

# IPs privadas de los servidores de app
output "app_private_ips" {
  value = data.aws_instances.app.private_ips
}
# Identificadores que usan las métricas de CloudWatch
output "alb_arn_suffix" {
  value = aws_lb.alb.arn_suffix
}

output "tg_arn_suffix" {
  value = aws_lb_target_group.tg-app.arn_suffix
}

output "asg_name" {
  value = aws_autoscaling_group.asg-app.name
}