# DevOps_v3-deploy

## Descripción General

Proyecto DevOps basado en una arquitectura de microservicios desplegada sobre AWS utilizando Docker, Kubernetes, GitHub Actions, Amazon ECR y Amazon EKS.

La solución está compuesta por:

* Frontend Web
* Microservicio de Ventas
* Microservicio de Despachos
* Bases de datos MySQL
* Infraestructura Kubernetes
* Automatización CI/CD

---

# Arquitectura

```text
                 ┌─────────────────┐
                 │     Frontend    │
                 │   (Nginx/Web)   │
                 └────────┬────────┘
                          │
             ┌────────────┴────────────┐
             │                         │
             ▼                         ▼

    ┌────────────────┐      ┌─────────────────┐
    │ Backend Ventas │      │ Backend Despacho│
    │ Spring Boot    │      │ Spring Boot     │
    └───────┬────────┘      └────────┬────────┘
            │                        │
            ▼                        ▼

    ┌────────────────┐      ┌─────────────────┐
    │ MySQL Ventas   │      │ MySQL Despachos │
    └────────────────┘      └─────────────────┘
```

---

# Tecnologías Utilizadas

## Backend

* Java 17
* Spring Boot
* Spring Data JPA
* Maven
* MySQL 8

## Frontend

* Docker
* Nginx

## DevOps

* Docker
* Docker Compose
* Kubernetes
* GitHub Actions
* Amazon ECR
* Amazon EKS
* AWS IAM

---

# Estructura del Proyecto

```text
DevOps_v3-deploy/
│
├── .github/
│   └── workflows/
│       ├── deploy_frontend.yml
│       ├── deploy_venta.yml
│       └── deploy_despacho.yml
│
├── back-Ventas_SpringBoot/
│   └── Springboot-API-REST/
│
├── back-Despachos_SpringBoot/
│   └── Springboot-API-REST-DESPACHO/
│
├── front_despacho/
│
├── infra/
│   └── k8s/
│       ├── backendventas.yml
│       ├── backdespachos.yml
│       ├── mysql-ventas.yml
│       ├── mysql-despachos.yml
│       ├── frontend.yml
│       └── secrets.yml
│
├── docker-compose.yml
└── .env
```

---


# Ejecución Local

## Requisitos

* Docker Desktop
* Docker Compose

Verificar instalación:

```bash
docker --version
docker compose version
```

## Levantar el entorno

```bash
docker compose up -d
```

Ver contenedores:

```bash
docker ps
```

Detener entorno:

```bash
docker compose down
```

---

# Servicios Disponibles

| Servicio      | Puerto |
| ------------- | ------ |
| Frontend      | 80     |
| API Ventas    | 8080   |
| API Despachos | 8081   |
| MySQL         | 3306   |

---

# Construcción de Imágenes

## Backend Ventas

```bash
cd back-Ventas_SpringBoot/Springboot-API-REST

mvn clean package

docker build -t backend-ventas .
```

## Backend Despachos

```bash
cd back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO

mvn clean package

docker build -t backend-despachos .
```

## Frontend

```bash
cd front_despacho

docker build -t frontend-app .
```

---

# Kubernetes

Los manifiestos se encuentran en:

```text
infra/k8s/
```

## Componentes

### Frontend

* Deployment
* Service LoadBalancer

### Backend Ventas

* Deployment
* Service
* Horizontal Pod Autoscaler (HPA)

### Backend Despachos

* Deployment
* Service
* Horizontal Pod Autoscaler (HPA)

### Bases de Datos

* MySQL Ventas
* MySQL Despachos

### Secrets

* Credenciales MySQL

---

# Despliegue Manual en Kubernetes

Aplicar secretos:

```bash
kubectl apply -f infra/k8s/secrets.yml
```

Aplicar bases de datos:

```bash
kubectl apply -f infra/k8s/mysql-ventas.yml

kubectl apply -f infra/k8s/mysql-despachos.yml
```

Aplicar microservicios:

```bash
kubectl apply -f infra/k8s/backendventas.yml

kubectl apply -f infra/k8s/backdespachos.yml
```

Aplicar frontend:

```bash
kubectl apply -f infra/k8s/frontend.yml
```

Ver recursos:

```bash
kubectl get pods

kubectl get svc

kubectl get deployments
```

---

# Pipeline CI/CD

La automatización se ejecuta cuando se realizan cambios sobre la rama:

```text
deploy
```

## Flujo

1. Push al repositorio.
2. GitHub Actions detecta cambios.
3. Construcción del proyecto.
4. Creación de imagen Docker.
5. Push a Amazon ECR.
6. Actualización de manifiestos Kubernetes.
7. Despliegue en Amazon EKS.
8. Reinicio controlado de Pods.

---

# GitHub Secrets Requeridos

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
```

---

# Amazon ECR

Repositorios utilizados:

```text
frontend-app
backend-ventas
backend-despachos
```

---

# Amazon EKS

Cluster utilizado:

```text
innovatech-cluster
```

Región:

```text
us-east-1
```

---

# Escalabilidad

Los servicios backend están configurados para:

* Múltiples réplicas
* Límites de CPU y memoria
* Autoescalado mediante HPA

---

## Kubernetes

* Utilizar StatefulSet para MySQL.
* Implementar Persistent Volumes.
* Configurar Ingress Controller.

## CI/CD

* Ejecutar pruebas automáticas.
* Versionar imágenes mediante tags.
* Incorporar análisis de vulnerabilidades.

---

# Autores

* William Cacéres
* Oscar Silva
* Israel Bordones

# Agradecimientos a:
* w.chamorro@fifa.com
