# ---------------------------------------------------------------
# VPC y IGW
# ---------------------------------------------------------------

resource "aws_vpc" "aws_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.nombreproyecto}-vpc" }
}

resource "aws_internet_gateway" "aws_igw" {
  vpc_id = aws_vpc.aws_vpc.id

  tags = { Name = "${var.nombreproyecto}-igw" }
}

# ---------------------------------------------------------------
# Subredes public
# ---------------------------------------------------------------


resource "aws_subnet" "sn-public-a" {
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = var.cidr_public_a
  availability_zone       = var.az_a
  map_public_ip_on_launch = true # las instancias reciben IP pública

  tags = {
    Name = "${var.nombreproyecto}-sn-public-a"
  }
}

resource "aws_subnet" "sn-public-b" {
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = var.cidr_public_b
  availability_zone       = var.az_b
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.nombreproyecto}-sn-public-b"
  }
}

# ---------------------------------------------------------------
# Subredes app
# ---------------------------------------------------------------


resource "aws_subnet" "sn-app-a" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = var.cidr_app_a
  availability_zone = var.az_a

  tags = {
    Name = "${var.nombreproyecto}-sn-app-a"
  }
}

resource "aws_subnet" "sn-app-b" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = var.cidr_app_b
  availability_zone = var.az_b

  tags = {
    Name = "${var.nombreproyecto}-sn-app-b"
  }
}
# ---------------------------------------------------------------
# Subredes BD
# ---------------------------------------------------------------


resource "aws_subnet" "sn-db-a" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = var.cidr_db_a
  availability_zone = var.az_a

  tags = {
    Name = "${var.nombreproyecto}-sn-db-a"
  }
}

resource "aws_subnet" "sn-db-b" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = var.cidr_db_b
  availability_zone = var.az_b

  tags = {
    Name = "${var.nombreproyecto}-sn-db-b"
  }
}
# ---------------------------------------------------------------
# NAT para app
# ---------------------------------------------------------------

resource "aws_nat_gateway" "nat-a" {
  allocation_id = aws_eip.eip-nat-a.id
  subnet_id     = aws_subnet.sn-public-a.id
  depends_on    = [aws_internet_gateway.aws_igw]

  tags = {
    Name = "${var.nombreproyecto}-nat-a"
  }
}

resource "aws_nat_gateway" "nat-b" {
  allocation_id = aws_eip.eip-nat-b.id
  subnet_id     = aws_subnet.sn-public-b.id
  depends_on    = [aws_internet_gateway.aws_igw]

  tags = {
    Name = "${var.nombreproyecto}-nat-b"
  }
}

resource "aws_eip" "eip-nat-a" {
  domain = "vpc"

  tags = {
    Name = "${var.nombreproyecto}-eip-nat-a"
  }
}

resource "aws_eip" "eip-nat-b" {
  domain = "vpc"

  tags = {
    Name = "${var.nombreproyecto}-eip-nat-b"
  }
}

# ---------------------------------------------------------------
# Routetables
# ---------------------------------------------------------------
resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_igw.id
  }

  tags = {
    Name = "${var.nombreproyecto}-rt-public"
  }
}
resource "aws_route_table" "rt-db" {
  vpc_id = aws_vpc.aws_vpc.id

  tags = {
    Name = "${var.nombreproyecto}-rt-db"
  }
}

resource "aws_route_table" "rt-app-a" {
  vpc_id = aws_vpc.aws_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-a.id
  }

  tags = {
    Name = "${var.nombreproyecto}-rt-app-a"
  }
}

resource "aws_route_table" "rt-app-b" {
  vpc_id = aws_vpc.aws_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-b.id
  }

  tags = {
    Name = "${var.nombreproyecto}-rt-app-b"
  }
}
# ---------------------------------------------------------------
# Asociaciones: conectan cada subred con su tabla de ruteo
# ---------------------------------------------------------------

resource "aws_route_table_association" "rtA-public-a" {
  subnet_id      = aws_subnet.sn-public-a.id
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "rtB-public-b" {
  subnet_id      = aws_subnet.sn-public-b.id
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "rtA-app-a" {
  subnet_id      = aws_subnet.sn-app-a.id
  route_table_id = aws_route_table.rt-app-a.id
}

resource "aws_route_table_association" "rtB-app-b" {
  subnet_id      = aws_subnet.sn-app-b.id
  route_table_id = aws_route_table.rt-app-b.id
}

resource "aws_route_table_association" "rtA-db-a" {
  subnet_id      = aws_subnet.sn-db-a.id
  route_table_id = aws_route_table.rt-db.id
}

resource "aws_route_table_association" "rtB-db-b" {
  subnet_id      = aws_subnet.sn-db-b.id
  route_table_id = aws_route_table.rt-db.id
}