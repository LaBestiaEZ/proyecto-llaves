#!/bin/bash

# Script de Inicialización Rápida
# Proyecto: Sistema de Llaves - Microservicios

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🚀 Inicialización del Proyecto Llaves                     ║${NC}"
echo -e "${BLUE}║   Arquitectura de Microservicios                            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Función para comprobar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verificar prerrequisitos
echo -e "${YELLOW}📋 Verificando prerrequisitos...${NC}"

if ! command_exists docker; then
    echo -e "${RED}❌ Docker no está instalado${NC}"
    echo -e "${YELLOW}Instala Docker desde: https://docs.docker.com/engine/install/${NC}"
    exit 1
fi

if ! command_exists docker compose; then
    echo -e "${RED}❌ Docker Compose no está disponible${NC}"
    echo -e "${YELLOW}Docker Compose V2 es requerido${NC}"
    exit 1
fi

if ! command_exists make; then
    echo -e "${RED}❌ Make no está instalado${NC}"
    echo -e "${YELLOW}Instala con: sudo apt install make${NC}"
    exit 1
fi

echo -e "${GREEN✓ Todos los prerrequisitos están instalados${NC}"
echo ""

# Verificar archivo .env
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📝 Creando archivo .env desde .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ Archivo .env creado${NC}"
    echo ""
    echo -e "${RED}⚠️  IMPORTANTE: Debes configurar las siguientes variables en .env:${NC}"
    echo -e "   ${YELLOW}1. NGROK_AUTHTOKEN - Obtener en https://dashboard.ngrok.com/get-started/your-authtoken${NC}"
    echo -e "   ${YELLOW}2. POSTGRES_PASSWORD - Cambia la contraseña por defecto${NC}"
    echo -e "   ${YELLOW}3. APP_SECRET - Genera con: openssl rand -hex 32${NC}"
    echo -e "   ${YELLOW}4. JWT_PASSPHRASE - Genera con: openssl rand -base64 32${NC}"
    echo ""
    read -p "Presiona ENTER cuando hayas configurado el archivo .env..."
else
    echo -e "${GREEN}✓ Archivo .env encontrado${NC}"
fi
echo ""

# Verificar NGROK_AUTHTOKEN
if grep -q "tu_token_de_ngrok_aqui" .env; then
    echo -e "${RED}❌ NGROK_AUTHTOKEN no está configurado en .env${NC}"
    echo -e "${YELLOW}Por favor, edita .env y configura tu token de ngrok${NC}"
    exit 1
fi

# Verificar frontend compilado
echo -e "${YELLOW}🎨 Verificando frontend compilado...${NC}"
if [ ! -d "frontend/dist" ]; then
    echo -e "${YELLOW}📦 Frontend no compilado. Compilando...${NC}"
    
    if [ ! -d "frontend/node_modules" ]; then
        echo -e "${YELLOW}   Instalando dependencias de npm...${NC}"
        cd frontend
        npm install
        cd ..
    fi
    
    echo -e "${YELLOW}   Compilando Angular para producción...${NC}"
    cd frontend
    npm run build
    cd ..
    
    echo -e "${GREEN}✓ Frontend compilado${NC}"
else
    echo -e "${GREEN}✓ Frontend ya está compilado${NC}"
fi
echo ""

# Levantar infraestructura
echo -e "${YELLOW}🚀 Levantando infraestructura Docker...${NC}"
make up
echo ""

# Dar tiempo a que los servicios se inicien
echo -e "${YELLOW}⏳ Esperando a que los servicios estén listos (30s)...${NC}"
sleep 30

# Instalar dependencias de Composer
echo -e "${YELLOW}📦 Instalando dependencias de Composer...${NC}"
make install
echo ""

# Ejecutar migraciones
echo -e "${YELLOW}🗄️  Ejecutando migraciones de base de datos...${NC}"
make migrate
echo ""

# Resumen final
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✅ Instalación completada exitosamente                    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📍 Servicios disponibles:${NC}"
echo -e "   ${YELLOW}• Aplicación Web:${NC}     http://localhost"
echo -e "   ${YELLOW}• API Backend:${NC}        http://localhost/api"
echo -e "   ${YELLOW}• Portainer:${NC}          http://localhost:9000"
echo -e "   ${YELLOW}• ngrok Dashboard:${NC}    http://localhost:4040"
echo -e "   ${YELLOW}• PostgreSQL:${NC}         localhost:5432"
echo ""
echo -e "${BLUE}🌐 URL Pública (ngrok):${NC}"
echo -e "   Ejecuta: ${YELLOW}make ngrok-url${NC}"
echo -e "   O visita: ${YELLOW}http://localhost:4040${NC}"
echo ""
echo -e "${BLUE}📚 Comandos útiles:${NC}"
echo -e "   ${YELLOW}make help${NC}           - Ver todos los comandos disponibles"
echo -e "   ${YELLOW}make logs${NC}           - Ver logs en tiempo real"
echo -e "   ${YELLOW}make ps${NC}             - Ver estado de contenedores"
echo -e "   ${YELLOW}make down${NC}           - Detener servicios"
echo -e "   ${YELLOW}make shell-backend${NC}  - Acceder al contenedor backend"
echo ""
echo -e "${GREEN}¡Listo para usar! 🎉${NC}"
