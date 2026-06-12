variable "aws_region" {
  description = "La region de AWS donde se crea toda la infraestructura ouyeah"
  type        = string
  default     = "us-east-1"
}

variable "labrole_name" {
  description = "Nombre del rol IAM "
  type        = string
  default     = "LabRole"
}

# Redes
variable "vpc_cidr" {
  description = "Rango de IPs para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_1_cidr" {
  description = "CIDR de la subnet pública 1"
  type        = string
  default     = "10.0.10.0/24"
}

variable "subnet_1_az" {
  description = "zona de habilitidad  de la subnet pública 1"
  type        = string
  default     = "us-east-1a"
}

variable "subnet_2_cidr" {
  description = "CIDR de la subnet pública 2"
  type        = string
  default     = "10.0.20.0/24"
}

variable "subnet_2_az" {
  description = "zona de habilitidad  de la subnet pública 2"
  type        = string
  default     = "us-east-1b"
}

# Cluster EKS
variable "cluster_name" {
  description = "Nombre del clúster EKS"
  type        = string
  default     = "innovatech-cluster"
}

# Node group
variable "node_group_name" {
  description = "Nombre del node group del clúster"
  type        = string
  default     = "workers"
}

variable "node_desired_size" {
  description = "Cantidad deseada de nodos"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Cantidad máxima de nodos"
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Cantidad mínima de nodos"
  type        = number
  default     = 1
}

variable "node_instance_types" {
  description = "Tipos de instancia para los workers"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "capacidad para el node group"
  type        = string
  default     = "ON_DEMAND"
}

# Repositorios ECR
variable "ecr_repo_ventas" {
  description = "Nombre del repositorio ECR para backend ventas"
  type        = string
  default     = "backend-ventas"
}

variable "ecr_repo_despachos" {
  description = "Nombre del repositorio ECR para backend despachos"
  type        = string
  default     = "backend-despachos"
}

variable "ecr_repo_frontend" {
  description = "Nombre del repositorio ECR para frontend"
  type        = string
  default     = "frontend-app"
}