# Dockerfile para compilar el frontend Angular
FROM node:22-alpine

WORKDIR /app

# Copiar archivos de dependencias
COPY frontend/package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar código fuente
COPY frontend/ ./

# Compilar para producción
RUN npm run build

# Script para copiar archivos al volumen
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'echo "Copiando frontend compilado al volumen..."' >> /entrypoint.sh && \
    echo 'cp -r /app/dist/browser/* /dist/ 2>/dev/null || cp -r /app/dist/* /dist/ || true' >> /entrypoint.sh && \
    echo 'echo "Frontend listo en /dist"' >> /entrypoint.sh && \
    echo 'ls -la /dist' >> /entrypoint.sh && \
    echo 'tail -f /dev/null' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
