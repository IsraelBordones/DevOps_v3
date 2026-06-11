# ------------------------------
# Dockerfile: frontend (React/Vite) + Nginx
# ------------------------------

# Etapa 1: Build de la aplicación
# - Usa Node para instalar dependencias y generar los assets estáticos.
FROM node:18-alpine AS build
WORKDIR /app

# Copia solo los manifiestos para aprovechar caché de Docker.
COPY package*.json ./

# Instala dependencias del proyecto.
RUN npm install

# Copia el resto del código fuente.
COPY . .

# Construye el frontend (genera /app/dist).
RUN npm run build

# Etapa 2: Servidor de producción
# - Nginx sirve los archivos estáticos.
# - Además incluye un nginx.conf que hace reverse-proxy hacia los backends.
FROM nginx:stable-alpine

# Reemplaza la config default de Nginx.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia el build (dist) al directorio de Nginx.
COPY --from=build /app/dist /usr/share/nginx/html

# Puerto HTTP.
EXPOSE 80

# Mantiene Nginx corriendo en foreground.
CMD ["nginx", "-g", "daemon off;"]

