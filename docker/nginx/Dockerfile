# Stage 1: Compilar frontend Angular con Node.js 22
FROM node:22-alpine AS frontend-builder

WORKDIR /app

# Copiar archivos de dependencias
COPY frontend/package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar código fuente
COPY frontend/ ./

# Compilar para producción
RUN npm run build

# Verificar dónde se generaron los archivos
RUN echo "=== Contenido de /app ===" && ls -la /app && \
    echo "=== Contenido de /app/dist ===" && ls -la /app/dist || true && \
    echo "=== Contenido de /app/dist/frontend ===" && ls -la /app/dist/frontend || true && \
    echo "=== Contenido de /app/dist/frontend/browser ===" && ls -la /app/dist/frontend/browser || true

# Stage 2: Nginx con el frontend compilado
FROM nginx:alpine

# Copiar configuración de Nginx
COPY docker/nginx/nginx.prod.conf /etc/nginx/conf.d/default.conf

# Copiar backend para PHP-FPM
RUN mkdir -p /var/www/backend

# Copiar frontend compilado desde el stage anterior
# Angular 17+ genera en dist/frontend/browser
COPY --from=frontend-builder /app/dist/frontend/browser /usr/share/nginx/html

# Verificar que se copiaron los archivos
RUN echo "=== Verificando archivos copiados ===" && \
    ls -la /usr/share/nginx/html && \
    if [ ! -f /usr/share/nginx/html/index.html ]; then \
        echo "ERROR: index.html no encontrado"; \
        exit 1; \
    fi

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
