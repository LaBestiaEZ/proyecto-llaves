# Dockerfile para compilar el frontend Angular
FROM node:22-alpine AS builder

WORKDIR /app

# Copiar archivos de dependencias
COPY frontend/package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar código fuente
COPY frontend/ ./

# Compilar para producción
RUN npm run build

# El resultado estará en /app/dist
