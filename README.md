# Obligatorio - Implementación de Soluciones Cloud
## Descripción

**Contexto.** Una empresa de venta online con infraestructura on-premise sufrió una degradación de performance tras una campaña publicitaria que llevó el tráfico de su e-commerce a valores fuera de lo previsto. Decidió migrar el frontend de la solución a AWS.

**Objetivo.** Diseñar e implementar en AWS, mediante Terraform, una solución equivalente a la actual (load balancer, dos servidores de aplicación, base de datos y respaldos) que sea tolerante a fallas, soporte picos de tráfico y tenga el firewall restringido al máximo.

## Requerimientos y versiones
## Instructivo de uso
## Arquitectura
## Servicios de AWS usados

| Servicio | Uso en la solución |
|---|---|
| Amazon VPC | Red aislada con 6 subredes en 2 AZ, Internet Gateway, 2 NAT Gateway y tablas de ruteo |
| Amazon EC2 | Servidores de aplicación y bastion; security groups; launch template; Elastic IPs |
| Elastic Load Balancing | Application Load Balancer, listener y target group |
| EC2 Auto Scaling | Auto Scaling Group y política de escalado por CPU |
| Amazon RDS | Base de datos MySQL Multi-AZ y respaldos (pendiente) |
| Amazon CloudWatch | Alarmas y dashboard (pendiente) |

## Uso de IA