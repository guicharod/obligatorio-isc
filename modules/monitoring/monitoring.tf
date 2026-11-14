# ---------------------------------------------------------------
# Notificaciones
# ---------------------------------------------------------------

# Topic donde publican las alarmas
resource "aws_sns_topic" "sns-alertas" {
  name = "${var.nombreproyecto}-sns-alertas"
}

# Suscripción por mail (AWS manda un mail que hay que confirmar)
resource "aws_sns_topic_subscription" "sns-email" {
  topic_arn = aws_sns_topic.sns-alertas.arn
  protocol  = "email"
  endpoint  = var.email_alertas
}

# ---------------------------------------------------------------
# Alarmas
# ---------------------------------------------------------------

# CPU promedio de los servidores de app (pico de tráfico)
resource "aws_cloudwatch_metric_alarm" "alarm-app-cpu" {
  alarm_name          = "${var.nombreproyecto}-app-cpu-alta"
  alarm_description   = "CPU promedio de los servidores de app mayor a 70 %"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions          = { AutoScalingGroupName = var.asg_name }
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  comparison_operator = "GreaterThanThreshold"
  threshold           = 70
  alarm_actions       = [aws_sns_topic.sns-alertas.arn]
  ok_actions          = [aws_sns_topic.sns-alertas.arn]
}

# Algún servidor no responde al health check del load balancer
resource "aws_cloudwatch_metric_alarm" "alarm-app-unhealthy" {
  alarm_name          = "${var.nombreproyecto}-app-unhealthy"
  alarm_description   = "Hay servidores de app fuera de servicio en el load balancer"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  dimensions          = { LoadBalancer = var.alb_arn_suffix, TargetGroup = var.tg_arn_suffix }
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.sns-alertas.arn]
  ok_actions          = [aws_sns_topic.sns-alertas.arn]
}

# CPU de la base de datos
resource "aws_cloudwatch_metric_alarm" "alarm-db-cpu" {
  alarm_name          = "${var.nombreproyecto}-db-cpu-alta"
  alarm_description   = "CPU de la base de datos mayor a 80 %"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  dimensions          = { DBInstanceIdentifier = var.db_identifier }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  comparison_operator = "GreaterThanThreshold"
  threshold           = 80
  alarm_actions       = [aws_sns_topic.sns-alertas.arn]
}

# Poco espacio libre en la base de datos (2 GB)
resource "aws_cloudwatch_metric_alarm" "alarm-db-storage" {
  alarm_name          = "${var.nombreproyecto}-db-storage-bajo"
  alarm_description   = "Espacio libre de la base de datos menor a 2 GB"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  dimensions          = { DBInstanceIdentifier = var.db_identifier }
  statistic           = "Minimum"
  period              = 300
  evaluation_periods  = 1
  comparison_operator = "LessThanThreshold"
  threshold           = 2147483648
  alarm_actions       = [aws_sns_topic.sns-alertas.arn]
}

# ---------------------------------------------------------------
# Dashboard
# ---------------------------------------------------------------

# Panel con las métricas principales de las tres capas
resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "${var.nombreproyecto}-dashboard"

  # jsonencode convierte la estructura de Terraform al JSON que pide CloudWatch
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6
        properties = {
          title  = "Load balancer: peticiones"
          region = var.region
          stat   = "Sum"
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ]
        }
      },
      {
        type = "metric", x = 12, y = 0, width = 12, height = 6
        properties = {
          title  = "Load balancer: servidores sanos y no sanos"
          region = var.region
          stat   = "Maximum"
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.tg_arn_suffix, "LoadBalancer", var.alb_arn_suffix],
            ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", var.tg_arn_suffix, "LoadBalancer", var.alb_arn_suffix]
          ]
        }
      },
      {
        type = "metric", x = 0, y = 6, width = 12, height = 6
        properties = {
          title  = "App: CPU promedio (%)"
          region = var.region
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]
          ]
        }
      },
      {
        type = "metric", x = 12, y = 6, width = 12, height = 6
        properties = {
          title  = "App: cantidad de instancias"
          region = var.region
          stat   = "Maximum"
          period = 60
          metrics = [
            ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", var.asg_name],
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", var.asg_name]
          ]
        }
      },
      {
        type = "metric", x = 0, y = 12, width = 12, height = 6
        properties = {
          title  = "Base de datos: CPU (%) y conexiones"
          region = var.region
          stat   = "Average"
          period = 300
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_identifier],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.db_identifier]
          ]
        }
      },
      {
        type = "metric", x = 12, y = 12, width = 12, height = 6
        properties = {
          title  = "Base de datos: espacio libre (bytes)"
          region = var.region
          stat   = "Minimum"
          period = 300
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.db_identifier]
          ]
        }
      }
    ]
  })
}