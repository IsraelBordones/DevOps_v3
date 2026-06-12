# ==============================
# Terraform: Infra AWS (EKS + ECR)
# ==============================

# 0) Providers
# Define qué proveedores se usarán (en este caso AWS).
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Origen del provider
      version = "~> 5.0"        # Rango de versión
    }
  }
}

# 1) Configuración del provider AWS
provider "aws" {
  region = var.aws_region # Región donde se crea toda la infraestructura
}

# 2) Rol IAM existente
# Se asume que ya existe un rol llamado "LabRole" (Learner Lab / Academy).
# Se usa su ARN para el cluster y node group.
data "aws_iam_role" "labrole" {
  name = var.labrole_name
}

# 3) Redes (VPC, Subnets, Internet Gateway, Route Tables)
resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr  # Rango de IPs para la VPC
  enable_dns_support   = true            # Habilita DNS interno
  enable_dns_hostnames = true           # Habilita hostnames
  tags = { Name = "innovatech-vpc" }   # Etiquetas
}

# Subnet pública 1 (us-east-1a)
resource "aws_subnet" "eks_subnet_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.subnet_1_cidr
  availability_zone         = var.subnet_1_az
  map_public_ip_on_launch = true

  # Etiqueta clave para que EKS sepa dónde crear LoadBalancers públicos
  tags = {
    Name = "innovatech-subnet-1"
    "kubernetes.io/role/elb" = "1"
  }
}

# Subnet pública 2 (us-east-1b)
resource "aws_subnet" "eks_subnet_2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.subnet_2_cidr
  availability_zone       = var.subnet_2_az
  map_public_ip_on_launch = true

  # Etiqueta clave para EKS
  tags = {
    Name = "innovatech-subnet-2"
    "kubernetes.io/role/elb" = "1"
  }
}

# Internet Gateway para salida a Internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags   = { Name = "innovatech-igw" }
}

# Route table con ruta por defecto hacia el IGW
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"                # Tráfico a cualquier destino
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "innovatech-route-table" }
}

# Asociaciones de route table con cada subnet
resource "aws_route_table_association" "rta_1" {
  subnet_id      = aws_subnet.eks_subnet_1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta_2" {
  subnet_id      = aws_subnet.eks_subnet_2.id
  route_table_id = aws_route_table.rt.id
}

# 4) Clúster EKS
resource "aws_eks_cluster" "eks" {
  name      = var.cluster_name
  role_arn = data.aws_iam_role.labrole.arn

  vpc_config {
    # Subnets donde se desplegarán recursos del clúster
    subnet_ids = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]
  }
}

# 5) Node group (workers) del clúster
resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = data.aws_iam_role.labrole.arn

  subnet_ids = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]

  # Autoscaling del número de nodos
  scaling_config {
    desired_size = var.node_desired_size  
                   max_size = var.node_max_size  
                   min_size = var.node_min_size
  }

  # Tipo de instancia para los workers
  instance_types = var.node_instance_types
  capacity_type = var.node_capacity_type
}

# 6) Repositorios ECR para imágenes Docker
resource "aws_ecr_repository" "backend_ventas_repo" {
  name = var.ecr_repo_ventas
  image_scanning_configuration { scan_on_push = true } # Escaneo al subir
  force_delete = true                                   # Permite borrar repo en destroy
}

resource "aws_ecr_repository" "backend_despachos_repo" {
  name = var.ecr_repo_despachos
  image_scanning_configuration { scan_on_push = true }
  force_delete = true
}

resource "aws_ecr_repository" "frontend_repo" {
  name = var.ecr_repo_frontend
  image_scanning_configuration { scan_on_push = true }
  force_delete = true
}

# 7) Outputs (para copiar y usar en CI/CD)
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

