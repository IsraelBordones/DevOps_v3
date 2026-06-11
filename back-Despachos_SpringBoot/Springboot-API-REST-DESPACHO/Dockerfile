# ------------------------------
# Dockerfile: backend despachos
# ------------------------------

# Etapa 1: Build
# - Usa una imagen Maven con JDK 17 para compilar el proyecto.
# - Construye un .jar en /app/target (sin ejecutar tests para acelerar).
FROM maven:3.8.5-openjdk-17-slim AS build
WORKDIR /app

# Copia TODO el código fuente al contenedor de build.
COPY . .

# Compila y empaqueta el proyecto en un jar.
# -DskipTests evita ejecutar tests durante el build de la imagen.
RUN mvn clean package -DskipTests

# Etapa 2: Runtime
# - Imagen más liviana con JRE (solo para ejecutar el jar).
# - Optimizada para reducir tamaño (por eso alpine).
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Seguridad: crea un usuario no-root.
# Esto evita ejecutar el proceso como root dentro del contenedor.
RUN addgroup -S devopsgroup && adduser -S devopsuser -G devopsgroup
USER devopsuser

# Copia el jar generado en la etapa de build hacia la etapa final.
COPY --from=build /app/target/*.jar app.jar

# Informa el puerto en el que escucha el backend.
EXPOSE 8081

# Punto de entrada: ejecuta el jar Spring Boot.
ENTRYPOINT ["java", "-jar", "app.jar"]

