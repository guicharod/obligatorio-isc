# ---------------------------------------------------------------
# Subnet group
# ---------------------------------------------------------------

# Subredes donde RDS puede ubicar la primaria y la standby (una por AZ)
resource "aws_db_subnet_group" "dbsng" {
  name       = "${var.nombreproyecto}-dbsng"
  subnet_ids = [var.sn_db_a_id, var.sn_db_b_id]

  tags = {
    Name = "${var.nombreproyecto}-dbsng"
  }
}

# ---------------------------------------------------------------
# Base de datos
# ---------------------------------------------------------------

# Multi-AZ: primaria en una AZ y standby en la otra
resource "aws_db_instance" "db" {
  identifier        = "${var.nombreproyecto}-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = var.db_nombre
  username = var.db_usuario
  password = var.db_password

  multi_az               = true # standby en la otra AZ
  db_subnet_group_name   = aws_db_subnet_group.dbsng.name
  vpc_security_group_ids = [var.sg_db_id]
  publicly_accessible    = false # sin IP pública

  # Al hacer destroy: true = borra sin snapshot (desarrollo)
  skip_final_snapshot = var.db_skip_final_snapshot

  tags = {
    Name = "${var.nombreproyecto}-db"
  }
}