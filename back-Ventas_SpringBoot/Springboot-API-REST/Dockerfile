# ------------------------------
# Dockerfile: backend ventas
# ------------------------------

# Etapa de construcción (build)
# - Usa Maven + JDK para compilar.
# - Genera el jar en /app/target.
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app

# Copia el código fuente del proyecto al contenedor de build.
COPY . .

# Empaqueta el proyecto.
# -DskipTests acelera la construcción de la imagen evitando ejecutar tests.
RUN mvn clean package -DskipTests

# Etapa de ejecución (runtime)
# - Imagen con JDK para correr el jar (en este caso se usa JDK en vez de JRE).
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copia el jar generado desde la etapa anterior.
COPY --from=build /app/target/*.jar app.jar

# Puerto que expone la API.
EXPOSE 8080

# Comando para iniciar la app Spring Boot.
ENTRYPOINT ["java", "-jar", "app.jar"]

