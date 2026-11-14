# ---------------------------------------------------------------
# Load balancer
# ---------------------------------------------------------------

# Application Load Balancer público, repartido en las dos AZ
resource "aws_lb" "alb" {
  name               = "${var.nombreproyecto}-alb"
  load_balancer_type = "application"
  internal           = false # accesible desde Internet
  security_groups    = [var.sg_alb_id]
  subnets            = [var.sn_public_a_id, var.sn_public_b_id]

  tags = {
    Name = "${var.nombreproyecto}-alb"
  }
}

# Grupo de servidores de app que reciben el tráfico
resource "aws_lb_target_group" "tg-app" {
  name     = "${var.nombreproyecto}-tg-app"
  port     = var.puerto_app
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name = "${var.nombreproyecto}-tg-app"
  }
}

# Escucha en el puerto 80 y reenvía al grupo de servidores
resource "aws_lb_listener" "listener-http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-app.arn
  }
}
# ---------------------------------------------------------------
# Detalles de la AMI
# ---------------------------------------------------------------

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# ---------------------------------------------------------------
# ASG con Servidores de aplicación
# ---------------------------------------------------------------

# Parametros de cada servidor de app que crea el Auto Scaling Group
resource "aws_launch_template" "lt-app" {
  name                   = "${var.nombreproyecto}-lt-app"
  image_id               = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.sg_app_id]

  # Script que corre al arrancar
  user_data = base64encode(file("${path.module}/userdata.sh"))

  tags = {
    Name = "${var.nombreproyecto}-lt-app"
  }
  # Métricas
  monitoring {
    enabled = true
  }
}

# Mantiene entre asg_min y asg_max servidores, repartidos en las dos AZ
resource "aws_autoscaling_group" "asg-app" {
  name                      = "${var.nombreproyecto}-asg-app"
  min_size                  = var.asg_min
  desired_capacity          = var.asg_deseado
  max_size                  = var.asg_max
  vpc_zone_identifier       = [var.sn_app_a_id, var.sn_app_b_id]
  target_group_arns         = [aws_lb_target_group.tg-app.arn] # registra las instancias en el load balancer
  health_check_type         = "ELB"                            # usa el health check del load balancer
  health_check_grace_period = 300                              # 5 minutos para instalarse antes de evaluar

  launch_template {
    id      = aws_launch_template.lt-app.id
    version = "$Latest"
  }

  # Nombre de las instancias que crea el ASG
  tag {
    key                 = "Name"
    value               = "${var.nombreproyecto}-app"
    propagate_at_launch = true
  }
  # Publica en CloudWatch la cantidad de instancias del grupo (dashboard)
  enabled_metrics = ["GroupInServiceInstances", "GroupDesiredCapacity"]
}

# Agrega o quita servidores para mantener la CPU promedio en 50 %
resource "aws_autoscaling_policy" "policy-cpu" {
  name                   = "${var.nombreproyecto}-policy-cpu"
  autoscaling_group_name = aws_autoscaling_group.asg-app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}

# Busca las instancias que creó el ASG, para mostrar sus IPs privadas
data "aws_instances" "app" {
  instance_tags = {
    Name = "${var.nombreproyecto}-app"
  }
  # Toma solo las instancias que están corriendo
  instance_state_names = ["running"]

  # Espera a que el ASG exista y haya lanzado las instancias
  depends_on = [aws_autoscaling_group.asg-app]
}

# ---------------------------------------------------------------
# Bastion
# ---------------------------------------------------------------

# Única máquina con SSH desde Internet (solo desde ip_admin)
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.sn_public_a_id
  vpc_security_group_ids = [var.sg_bastion_id]

  tags = {
    Name = "${var.nombreproyecto}-bastion"
  }
}

