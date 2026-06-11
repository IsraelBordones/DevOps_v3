terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Asumiendo que usas AWS Academy / Learner Lab
data "aws_iam_role" "labrole" {
  name = "LabRole"
}

# 1. Redes (VPC, Subnets, IGW, Route Tables)
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "innovatech-vpc" }
}

resource "aws_subnet" "eks_subnet_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  
  # ESTO ES CLAVE: EKS necesita esta etiqueta para saber dónde crear los LoadBalancers públicos
  tags = { 
    Name = "innovatech-subnet-1"
    "kubernetes.io/role/elb" = "1" 
  } 
}

resource "aws_subnet" "eks_subnet_2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  
  # ESTO ES CLAVE: EKS necesita esta etiqueta para saber dónde crear los LoadBalancers públicos
  tags = { 
    Name = "innovatech-subnet-2"
    "kubernetes.io/role/elb" = "1" 
  } 
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags   = { Name = "innovatech-igw" }
}

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

# 2. Clúster EKS y Nodos Workers
resource "aws_eks_cluster" "eks" {
  name     = "innovatech-cluster"
  role_arn = data.aws_iam_role.labrole.arn
  vpc_config {
    subnet_ids = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]
  }
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "workers"
  node_role_arn   = data.aws_iam_role.labrole.arn
  subnet_ids      = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]
  
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  
  # t3.medium aguanta bien para 3 microservicios sin que se te caiga el clúster
  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"
}

# 3. Repositorios ECR (Donde guardaremos las imágenes Docker)
resource "aws_ecr_repository" "backend_ventas_repo" {
  name = "backend-ventas"
  image_scanning_configuration { scan_on_push = true }
  force_delete = true
}

resource "aws_ecr_repository" "backend_despachos_repo" {
  name = "backend-despachos"
  image_scanning_configuration { scan_on_push = true }
  force_delete = true
}

resource "aws_ecr_repository" "frontend_repo" {
  name = "frontend-app"
  image_scanning_configuration { scan_on_push = true }
  force_delete = true
}

# 4. Outputs (Te los dejo listos para copiarlos cuando armemos el GitHub Actions)
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