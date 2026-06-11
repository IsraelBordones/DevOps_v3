# 🚀 Aprovisionamiento de Infraestructura y Despliegue Automatizado - Innovatech Chile

Este repositorio contiene el código de Infraestructura como Código (IaC) en Terraform, la configuración de contenedorización con Docker y el pipeline automatizado de CI/CD para el despliegue del sistema de la empresa Innovatech Chile, cumpliendo con los requisitos de la Evaluación Parcial N°2.

---

## 🗺️ 1. Diagrama de Arquitectura de Red

El diseño de la infraestructura implementado en AWS asegura el aislamiento de los recursos y el cumplimiento de las políticas de seguridad:

```text
       [ INTERNET ]
            │
            │ (Puerto 80)
            ▼
┌──────────────────────────────────────┐
│ AWS EC2 (Host de Producción)        │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ Docker Engine (Bridge Network) │  │
│  │                                │  │
│  │   ┌──────────┐                 │  │
│  │   │ Frontend │ (Nginx)         │  │
│  │   └────┬─────┘                 │  │
│  │        │ (Red Interna)         │  │
│  │        ▼                       │  │
│  │   ┌──────────┐   ┌──────────┐  │  │
│  │   │  APIs    ├──►│  MySQL   │  │  │
│  │   │ (Spring) │   │  (Vol)   │  │  │
│  │   └──────────┘   └──────────┘  │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘

📁 2. Estructura del Repositorio
A continuación se detalla la organización de los archivos del proyecto en la rama deploy:

📂 proyecto-semestral-2/
 ├── 📂 .github/
 │    └── 📂 workflows/
 │         └── 📄 ci.yml                  # Pipeline de GitHub Actions (CI/CD)
 ├── 📂 back-Despachos_SpringBoot/        # Microservicio de Despachos (Backend)
 │    └── 📄 Dockerfile                   # Multi-stage build (Usuario No-Root)
 ├── 📂 back-Ventas_SpringBoot/           # Microservicio de Ventas (Backend)
 │    └── 📄 Dockerfile                   # Multi-stage build optimizado
 ├── 📂 front_despacho/                   # Aplicación Single Page (Frontend)
 │    └── 📄 Dockerfile                   # Servidor de producción con Nginx
 ├── 📂 infra/
 │    └── 📂 etapa_1/                     # Código de Infraestructura como Código (IaC)
 │         ├── 📄 main.tf                 # Recursos principales (EC2, SG, VPC)
 │         ├── 📄 variables.tf            # Variables de configuración
 │         └── 📄 outputs.tf              # Salidas de datos (IP Pública)
 ├── 📄 docker-compose.yml                # Orquestación del Stack completo
 ├── 📄 .gitignore                        # Exclusión de archivos temporales
 └── 📄 README.md                         # Documentación técnica principal

 🛠️ 3. Componentes del Stack (Docker Compose)
El stack de servicios se administra de forma centralizada mediante docker-compose.yml, aislando los componentes en una red interna tipo bridge (red-interna):

proyecto-db: Base de datos MySQL 8.0, expuesta internamente en el puerto 3306.

service-ventas / service-despachos: APIs REST en Spring Boot (Java 17), expuestas en los puertos 8080 y 8081.

frontend: Servidor de producción optimizado con Nginx, expuesto de cara al público en el puerto 80.

💾 4. Estrategia de Persistencia de Datos
Para garantizar la continuidad operativa y evitar la pérdida de información crítica, se implementó un Named Volume (Volumen con nombre) administrado por Docker:

volumes:
  mysql_data:
Justificación Técnica:
Seguridad: Los volúmenes con nombre son gestionados en un directorio exclusivo de Docker dentro del sistema de archivos de Linux, impidiendo alteraciones accidentales desde el Host EC2.

Rendimiento: Ofrece una velocidad de lectura/escritura nativa significativamente mayor en entornos cloud en comparación con los montajes de carpetas locales (bind mounts).

⚙️ 5. Optimización de Contenedores (Dockerfile)
Multi-Stage Build: Se separó la etapa de compilación de la de ejecución final. Esto permite generar imágenes de producción ultra-livianas basadas en Alpine, reduciendo el consumo de almacenamiento y minimizando la superficie de ataque.

Principio de Mínimo Privilegio (Usuario No-Root): En el servicio de despachos, los procesos del contenedor no corren como root. Se configuró un usuario exclusivo sin privilegios del sistema:

Dockerfile
RUN addgroup -S devopsgroup && adduser -S devopsuser -G devopsgroup
USER devopsuser

🚀 6. Pipeline de Integración y Despliegue Continuo (CI/CD)
La automatización completa está implementada en GitHub Actions mediante el workflow .github/workflows/ci.yml.

Flujo de Trabajo:
Trigger: Se activa exclusivamente al realizar un push sobre la rama deploy.

Build & Push: Autentica de forma segura usando GitHub Secrets (AWS_ACCESS_KEY_ID, etc.), compila el código y publica las imágenes en Amazon ECR.

Deploy: Mediante una conexión remota vía SSH, transfiere el docker-compose.yml, ejecuta docker compose pull y levanta las nuevas versiones en la EC2 de producción sin interrumpir el servicio.

💻 7. Guía de Despliegue
Despliegue de Infraestructura (Terraform)
Para aprovisionar los recursos en AWS, navegue a la carpeta de infraestructura y ejecute:

Bash
cd infra/etapa_1
terraform init
terraform plan
terraform apply -auto-approve

Ejecución Local del Stack (Docker)
Para levantar todo el ecosistema de microservicios de manera local en su máquina de desarrollo, ejecute en la raíz del proyecto:

Bash
docker compose up -d --build

📅 8. Gestión de Proyecto y Cultura DevOps (Trello)
Para la planificación, asignación de tareas y trazabilidad del trabajo en dupla, se aplicaron prácticas de metodologías ágiles mediante un tablero Kanban en Trello.

https://trello.com/invite/b/69aefef59cf3eab029cee866/ATTI8c958a86b45801b7b99f603c4e2da4c6FC4B08EB/innovatech-sistema-despachos-ventas

```
# Proyecto Innovatech
