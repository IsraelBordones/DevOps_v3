# Etapa 1: Construcción (Pesa harto, pero se queda en GitHub)
FROM maven:3.8.5-openjdk-17-slim AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Etapa 2: Ejecución (Ultra liviana para la t3.micro)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Crear usuario sin privilegios (Exigencia de la rúbrica)
RUN addgroup -S devopsgroup && adduser -S devopsuser -G devopsgroup
USER devopsuser

COPY --from=build /app/target/*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]