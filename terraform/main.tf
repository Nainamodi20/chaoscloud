resource "aws_vpc" "chaoscloud" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = false

  tags = {
    Name    = "chaoscloud-vpc"
    Project = "CHAOSCLOUD"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.chaoscloud.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "chaoscloud-public-1a"
    Project = "CHAOSCLOUD"
    Type    = "public"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.chaoscloud.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "chaoscloud-public-1b"
    Project = "CHAOSCLOUD"
    Type    = "public"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id                                      = aws_vpc.chaoscloud.id
  cidr_block                                  = "10.0.11.0/24"
  availability_zone                           = "ap-south-1a"
  map_public_ip_on_launch                     = false
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name    = "chaoscloud-private-1a"
    Project = "CHAOSCLOUD"
    Type    = "private"
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id                  = aws_vpc.chaoscloud.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

  tags = {
    Name    = "chaoscloud-private-1b"
    Project = "CHAOSCLOUD"
    Type    = "private"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "chaoscloud" {
  vpc_id = aws_vpc.chaoscloud.id

  tags = {
    Name    = "chaoscloud-igw"
    Project = "CHAOSCLOUD"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.chaoscloud.id

  tags = {
    Name    = "chaoscloud-public-rt"
    Project = "CHAOSCLOUD"
    Type    = "public"
  }
}

# Route public traffic to the Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.chaoscloud.id
}

# Associate public subnet 1a
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

# Associate public subnet 1b
resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.chaoscloud.id

  tags = {
    Name    = "chaoscloud-private-rt"
    Project = "CHAOSCLOUD"
    Type    = "private"
  }
}

# Associate private subnet 1a
resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private.id
}

# Associate private subnet 1b
resource "aws_route_table_association" "private_1b" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private.id
}

# Application Security Group
resource "aws_security_group" "application" {
  name        = "chaoscloud-application-sg"
  description = "Security group for CHAOSCLOUD application instances"
  vpc_id      = aws_vpc.chaoscloud.id

  # SSH access from administrator only
  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Public application access
  ingress {
    description = "HTTP application access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application metrics access from monitoring server
  ingress {
    description     = "Application metrics"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring.id]
  }

  # Node exporter metrics from monitoring server
  ingress {
    description     = "Node exporter metrics"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "chaoscloud-application-sg"
    Project = "CHAOSCLOUD"
  }
}

# Monitoring Security Group
resource "aws_security_group" "monitoring" {
  name        = "chaoscloud-monitoring-sg"
  description = "Security group for Prometheus and Grafana"
  vpc_id      = aws_vpc.chaoscloud.id

  # SSH administration
  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Grafana dashboard
  ingress {
    description = "Grafana dashboard"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Prometheus web interface
  ingress {
    description = "Prometheus interface"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "chaoscloud-monitoring-sg"
    Project = "CHAOSCLOUD"
  }
}

