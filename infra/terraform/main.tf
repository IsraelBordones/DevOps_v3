# ==============================
# Terraform: Infra AWS (EKS + ECR)
# ==============================

# 0) Providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 1) Configuracion del provider AWS
provider "aws" {
  region = var.aws_region
}

# 2) Rol IAM existente (LabRole de AWS Academy)
data "aws_iam_role" "labrole" {
  name = var.labrole_name
}

# 3) Redes (VPC, Subnets, Internet Gateway, Route Tables)
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "innovatech-vpc" }
}

# Subnet publica 1 (us-east-1a)
resource "aws_subnet" "eks_subnet_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.subnet_1_cidr
  availability_zone       = var.subnet_1_az
  map_public_ip_on_launch = true
  tags = {
    Name                     = "innovatech-subnet-1"
    "kubernetes.io/role/elb" = "1"
  }
}

# Subnet publica 2 (us-east-1b)
resource "aws_subnet" "eks_subnet_2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.subnet_2_cidr
  availability_zone       = var.subnet_2_az
  map_public_ip_on_launch = true
  tags = {
    Name                     = "innovatech-subnet-2"
    "kubernetes.io/role/elb" = "1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags   = { Name = "innovatech-igw" }
}

# Route table con ruta por defecto hacia el IGW
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "innovatech-route-table" }
}

resource "aws_route_table_association" "rta_1" {
  subnet_id      = aws_subnet.eks_subnet_1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta_2" {
  subnet_id      = aws_subnet.eks_subnet_2.id
  route_table_id = aws_route_table.rt.id
}

# ==============================
# 3.1) Security Group del cluster EKS
# ==============================
resource "aws_security_group" "eks_sg" {
  name        = "${var.cluster_name}-sg"
  description = "Security Group para el cluster EKS control plane y nodos"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    description = "HTTP desde Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS desde Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Trafico interno entre nodos del cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Salida sin restricciones"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.cluster_name}-sg" }
}

# ==============================
# 3.2) Security Group para el Frontend
# ==============================
resource "aws_security_group" "frontend_sg" {
  name        = "innovatech-frontend-sg"
  description = "Security Group para el frontend acceso publico HTTP y HTTPS"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    description = "HTTP publico al frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS publico al frontend"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Salida sin restricciones"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "innovatech-frontend-sg" }
}

# ==============================
# 3.3) Security Group para el Backend
# ==============================
resource "aws_security_group" "backend_sg" {
  name        = "innovatech-backend-sg"
  description = "Security Group para los backends acceso solo desde el frontend"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    description     = "Trafico desde el frontend al backend ventas"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  ingress {
    description     = "Trafico desde el frontend al backend despachos"
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    description = "Salida sin restricciones"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "innovatech-backend-sg" }
}

# ==============================
# 3.4) Security Group para la Base de Datos
# ==============================
resource "aws_security_group" "db_sg" {
  name        = "innovatech-db-sg"
  description = "Security Group para MySQL acceso solo desde el backend"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    description     = "MySQL solo desde el backend"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }

  egress {
    description = "Salida sin restricciones"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "innovatech-db-sg" }
}

# ==============================
# 4) Cluster EKS
# ==============================
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = data.aws_iam_role.labrole.arn

  vpc_config {
    subnet_ids         = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]
    security_group_ids = [aws_security_group.eks_sg.id]
  }
}

# 5) Node group (workers)
resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = data.aws_iam_role.labrole.arn
  subnet_ids      = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = var.node_instance_types
  capacity_type  = var.node_capacity_type
}

# ==============================
# 6) Repositorios ECR
# ==============================
resource "aws_ecr_repository" "backend_ventas_repo" {
  name         = var.ecr_repo_ventas
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "backend_despachos_repo" {
  name         = var.ecr_repo_despachos
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend_repo" {
  name         = var.ecr_repo_frontend
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ==============================
# 7) Outputs
# ==============================
output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "repo_ventas_url" {
  value = aws_ecr_repository.backend_ventas_repo.repository_url
}

output "repo_despachos_url" {
  value = aws_ecr_repository.backend_despachos_repo.repository_url
}

output "repo_frontend_url" {
  value = aws_ecr_repository.frontend_repo.repository_url
}

output "sg_frontend_id" {
  description = "ID del Security Group del Frontend"
  value       = aws_security_group.frontend_sg.id
}

output "sg_backend_id" {
  description = "ID del Security Group del Backend"
  value       = aws_security_group.backend_sg.id
}

output "sg_db_id" {
  description = "ID del Security Group de la Base de Datos"
  value       = aws_security_group.db_sg.id
}
