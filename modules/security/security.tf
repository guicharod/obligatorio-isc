# ---------------------------------------------------------------
# Load balancer
# ---------------------------------------------------------------

resource "aws_security_group" "sg-alb" {
  name        = "${var.nombreproyecto}-sg-alb"
  description = "HTTP desde Internet"
  vpc_id      = var.vpc_id

  # Entrada: HTTP desde cualquier lado
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida: solo hacia los servidores de app
  egress {
    from_port   = var.puerto_app
    to_port     = var.puerto_app
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.nombreproyecto}-sg-alb"
  }
}

# ---------------------------------------------------------------
# Bastion
# ---------------------------------------------------------------

resource "aws_security_group" "sg-bastion" {
  name        = "${var.nombreproyecto}-sg-bastion"
  description = "SSH solo desde la IP del administrador"
  vpc_id      = var.vpc_id

  # Entrada: SSH solo desde mi IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ip_admin]
  }

  # Salida: SSH solo hacia adentro de la VPC
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.nombreproyecto}-sg-bastion"
  }
}

# ---------------------------------------------------------------
# Servidores de aplicación
# ---------------------------------------------------------------

resource "aws_security_group" "sg-app" {
  name        = "${var.nombreproyecto}-sg-app"
  description = "Ingreso solo desde el load balancer y SSH desde el bastion"
  vpc_id      = var.vpc_id

  # Entrada: Desde el load balancer
  ingress {
    from_port       = var.puerto_app
    to_port         = var.puerto_app
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-alb.id]
  }

  # Entrada: SSH solo desde el bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-bastion.id]
  }

  # Salida a Internet para instalar paquetes
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida: hacia la base de datos
  egress {
    from_port   = var.puerto_db
    to_port     = var.puerto_db
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.nombreproyecto}-sg-app"
  }
}

# ---------------------------------------------------------------
# Base de datos
# ---------------------------------------------------------------

resource "aws_security_group" "sg-db" {
  name   = "${var.nombreproyecto}-sg-db"
  description = "Solo desde los servidores de app"
  vpc_id = var.vpc_id

  # Entrada: solo desde los servidores de app
  ingress {
    from_port       = var.puerto_db
    to_port         = var.puerto_db
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-app.id]
  }

  # Sin bloque egress

  tags = {
    Name = "${var.nombreproyecto}-sg-db"
  }
}