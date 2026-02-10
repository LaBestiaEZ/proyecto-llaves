#!/bin/bash

# Script de Verificación Automática
# Práctica Evaluativa Final - Microservicios

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🔍 Verificación Automática de la Práctica                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

errors=0
warnings=0

# Función para chequear
check() {
    local description="$1"
    local command="$2"
    local critical="${3:-true}"
    
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}  ✅ ${description}${NC}"
        return 0
    else
        if [ "$critical" = "true" ]; then
            echo -e "${RED}  ❌ ${description}${NC}"
            ((errors++))
        else
            echo -e "${YELLOW}  ⚠️  ${description}${NC}"
            ((warnings++))
        fi
        return 1
    fi
}

# 1. ARCHIVOS DE CONFIGURACIÓN
echo -e "${BLUE}📁 Verificando archivos de configuración...${NC}"
check ".env existe" "test -f .env"
check ".env.example existe" "test -f .env.example"
check "compose.yml existe" "test -f compose.yml"
check "Makefile existe" "test -f Makefile"
check "docker/nginx/nginx.prod.conf existe" "test -f docker/nginx/nginx.prod.conf"
echo ""

# 2. GITIGNORE
echo -e "${BLUE}🔒 Verificando .gitignore...${NC}"
check ".env en .gitignore" "grep -q '^\.env$' .gitignore"
check "backend/.env en .gitignore" "grep -q '/backend/\.env$' .gitignore"
echo ""

# 3. VARIABLES DE ENTORNO
echo -e "${BLUE}🔐 Verificando variables de entorno...${NC}"
if [ -f .env ]; then
    check "NGROK_AUTHTOKEN configurado" "grep -q 'NGROK_AUTHTOKEN=.*[a-zA-Z0-9]' .env && ! grep -q 'tu_token_de_ngrok_aqui' .env"
    check "POSTGRES_PASSWORD configurado" "grep -q 'POSTGRES_PASSWORD=' .env && ! grep -q 'password_seguro_aqui' .env" false
    check "APP_SECRET configurado" "grep -q 'APP_SECRET=.*' .env && ! grep -q 'generar_' .env" false
fi
echo ""

# 4. COMPOSE.YML
echo -e "${BLUE}🐳 Verificando compose.yml...${NC}"
check "compose.yml válido" "docker compose config --quiet"
if docker compose config &>/dev/null; then
    check "Servicio 'db' definido" "docker compose config | grep -q 'db:'"
    check "Servicio 'backend' definido" "docker compose config | grep -q 'backend:'"
    check "Servicio 'webserver' definido" "docker compose config | grep -q 'webserver:'"
    check "Servicio 'portainer' definido" "docker compose config | grep -q 'portainer:'"
    check "Servicio 'ngrok' definido" "docker compose config | grep -q 'ngrok:'"
    check "Red 'llaves-network' definida" "docker compose config | grep -q 'llaves-network'"
    check "Volumen 'postgres_data' definido" "docker compose config | grep -q 'postgres_data'"
fi
echo ""

# 5. MAKEFILE
echo -e "${BLUE}⚙️  Verificando Makefile...${NC}"
check "Comando 'make up' definido" "grep -q '^up:' Makefile"
check "Comando 'make down' definido" "grep -q '^down:' Makefile"
check "Comando 'make migrate' definido" "grep -q '^migrate:' Makefile"
check "Comando 'make install' definido" "grep -q '^install:' Makefile"
check "Comando 'make logs' definido" "grep -q '^logs:' Makefile"
check "Comando 'make help' definido" "grep -q '^help:' Makefile"
echo ""

# 6. CONFIGURACIÓN DE NGINX
echo -e "${BLUE}🌐 Verificando configuración de Nginx...${NC}"
if [ -f docker/nginx/nginx.prod.conf ]; then
    check "Nginx: location /api configurado" "grep -q 'location /api' docker/nginx/nginx.prod.conf"
    check "Nginx: location / configurado" "grep -q 'location /' docker/nginx/nginx.prod.conf"
    check "Nginx: FastCGI configurado" "grep -q 'fastcgi_pass' docker/nginx/nginx.prod.conf"
fi
echo ""

# 7. CORS
echo -e "${BLUE}🔄 Verificando configuración de CORS...${NC}"
if [ -f backend/config/packages/nelmio_cors.yaml ]; then
    check "CORS: ngrok permitido" "grep -q 'ngrok' backend/config/packages/nelmio_cors.yaml"
fi
echo ""

# 8. FRONTEND
echo -e "${BLUE}🎨 Verificando frontend...${NC}"
check "node_modules instalado" "test -d frontend/node_modules" false
check "Frontend compilado (dist)" "test -d frontend/dist" false
if [ -f frontend/src/environments/environment.prod.ts ]; then
    check "Environment.prod usa ruta relativa" "grep -q \"apiUrl.*'/api'\" frontend/src/environments/environment.prod.ts" false
fi
echo ""

# 9. SERVICIOS DOCKER (si están corriendo)
echo -e "${BLUE}🚀 Verificando servicios Docker...${NC}"
if docker compose ps 2>/dev/null | grep -q "Up"; then
    echo -e "${GREEN}  Servicios detectados en ejecución:${NC}"
    docker compose ps --format "table {{.Name}}\t{{.Status}}" | tail -n +2 | while read line; do
        echo -e "    ${GREEN}→${NC} $line"
    done
    echo ""
    
    # Verificar conectividad
    check "PostgreSQL responde" "docker compose exec -T db pg_isready -U llaves_user"
    check "Backend accesible (puerto 9000)" "docker compose exec -T webserver nc -z backend 9000" false
    check "Frontend en http://localhost" "curl -sf http://localhost > /dev/null" false
    check "Backend API en http://localhost/api" "curl -sf http://localhost/api > /dev/null" false
    check "Portainer en http://localhost:9000" "curl -sf http://localhost:9000 > /dev/null" false
    check "ngrok dashboard en http://localhost:4040" "curl -sf http://localhost:4040 > /dev/null" false
else
    echo -e "${YELLOW}  ⚠️  Servicios NO están corriendo${NC}"
    echo -e "${YELLOW}     Ejecuta: make up${NC}"
fi
echo ""

# 10. GIT
echo -e "${BLUE}📦 Verificando Git...${NC}"
if [ -d .git ]; then
    check "Repositorio Git inicializado" "test -d .git"
    
    # Verificar que .env NO esté en staging
    if [ -f .env ]; then
        if git ls-files --error-unmatch .env 2>/dev/null; then
            echo -e "${RED}  ❌ .env está siendo trackeado por Git (ELIMINAR)${NC}"
            ((errors++))
        else
            echo -e "${GREEN}  ✅ .env NO está en Git${NC}"
        fi
    fi
    
    # Verificar que .env.example SÍ esté
    if git ls-files --error-unmatch .env.example 2>/dev/null; then
        echo -e "${GREEN}  ✅ .env.example está en Git${NC}"
    else
        echo -e "${YELLOW}  ⚠️  .env.example NO está en Git (añadir)${NC}"
        ((warnings++))
    fi
else
    echo -e "${YELLOW}  ⚠️  No es un repositorio Git${NC}"
    ((warnings++))
fi
echo ""

# RESUMEN FINAL
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    RESUMEN FINAL                            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${GREEN}🎉 ¡PERFECTO! Todos los checks pasaron${NC}"
    echo -e "${GREEN}   Listo para entregar la práctica${NC}"
    exit 0
elif [ $errors -eq 0 ]; then
    echo -e "${YELLOW}⚠️  ${warnings} advertencia(s) encontrada(s)${NC}"
    echo -e "${YELLOW}   La práctica funciona pero revisa las advertencias${NC}"
    exit 0
else
    echo -e "${RED}❌ Se encontraron ${errors} error(es) crítico(s)${NC}"
    if [ $warnings -gt 0 ]; then
        echo -e "${YELLOW}   Y ${warnings} advertencia(s)${NC}"
    fi
    echo -e "${RED}   Corrige los errores antes de entregar${NC}"
    exit 1
fi
