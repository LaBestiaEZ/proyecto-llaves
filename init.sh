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

echo -e "${GREEN}✓ Todos los prerrequisitos están instalados${NC}"
echo ""

# Verificar archivo .env
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}📝 Creando archivo .env...${NC}"
    cp .env.example .env
    
    # Generar claves automáticamente
    echo -e "${YELLOW}🔑 Generando claves de seguridad...${NC}"
    
    # Generar APP_SECRET
    APP_SECRET=$(openssl rand -hex 32)
    sed -i "s/generar_secreto_de_32_caracteres_aleatorios/${APP_SECRET}/" .env
    echo -e "${GREEN}✓ APP_SECRET generado${NC}"
    
    # Generar JWT_PASSPHRASE
    JWT_PASSPHRASE=$(openssl rand -base64 32 | tr -d '\n')
    sed -i "s/generar_passphrase_seguro/${JWT_PASSPHRASE}/" .env
    echo -e "${GREEN}✓ JWT_PASSPHRASE generado${NC}"
    
    # Generar POSTGRES_PASSWORD
    POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr -d '\n')
    sed -i "s/password_seguro_aqui/${POSTGRES_PASSWORD}/" .env
    echo -e "${GREEN}✓ POSTGRES_PASSWORD generado${NC}"
    
    # Usar nombre de base de datos por defecto
    sed -i "s/nombre_base_datos/llaves_produccion/" .env
    sed -i "s/usuario_db/llaves_user/" .env
    
    echo ""
    echo -e "${YELLOW}🌐 Configurando ngrok...${NC}"
    echo -e "${BLUE}Para obtener tu token de ngrok:${NC}"
    echo -e "   1. Visita: ${YELLOW}https://dashboard.ngrok.com/get-started/your-authtoken${NC}"
    echo -e "   2. Copia tu authtoken"
    echo ""
    read -p "Ingresa tu NGROK_AUTHTOKEN: " NGROK_TOKEN
    
    if [ -z "$NGROK_TOKEN" ]; then
        echo -e "${RED}❌ No ingresaste el token de ngrok${NC}"
        echo -e "${YELLOW}Puedes configurarlo después editando el archivo .env${NC}"
    else
        sed -i "s/tu_token_de_ngrok_aqui/${NGROK_TOKEN}/" .env
        echo -e "${GREEN}✓ NGROK_AUTHTOKEN configurado${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}✓ Archivo .env configurado completamente${NC}"
else
    echo -e "${GREEN}✓ Archivo .env encontrado${NC}"
    
    # Verificar si las claves aún tienen valores por defecto y generarlas
    if grep -q "generar_secreto_de_32_caracteres_aleatorios" .env; then
        echo -e "${YELLOW}🔑 Generando APP_SECRET...${NC}"
        APP_SECRET=$(openssl rand -hex 32)
        sed -i "s/generar_secreto_de_32_caracteres_aleatorios/${APP_SECRET}/" .env
        echo -e "${GREEN}✓ APP_SECRET generado${NC}"
    fi
    
    if grep -q "generar_passphrase_seguro" .env; then
        echo -e "${YELLOW}🔑 Generando JWT_PASSPHRASE...${NC}"
        JWT_PASSPHRASE=$(openssl rand -base64 32 | tr -d '\n')
        sed -i "s/generar_passphrase_seguro/${JWT_PASSPHRASE}/" .env
        echo -e "${GREEN}✓ JWT_PASSPHRASE generado${NC}"
    fi
    
    if grep -q "password_seguro_aqui" .env; then
        echo -e "${YELLOW}🔑 Generando POSTGRES_PASSWORD...${NC}"
        POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr -d '\n')
        sed -i "s/password_seguro_aqui/${POSTGRES_PASSWORD}/" .env
        echo -e "${GREEN}✓ POSTGRES_PASSWORD generado${NC}"
    fi
fi
echo ""

# Verificar NGROK_AUTHTOKEN
if grep -q "tu_token_de_ngrok_aqui" .env; then
    echo -e "${YELLOW}⚠️  NGROK_AUTHTOKEN no está configurado${NC}"
    echo -e "${BLUE}Para obtener tu token de ngrok:${NC}"
    echo -e "   Visita: ${YELLOW}https://dashboard.ngrok.com/get-started/your-authtoken${NC}"
    echo ""
    read -p "¿Deseas configurarlo ahora? (s/N): " configurar_ngrok
    
    if [[ "$configurar_ngrok" =~ ^[Ss]$ ]]; then
        read -p "Ingresa tu NGROK_AUTHTOKEN: " NGROK_TOKEN
        if [ ! -z "$NGROK_TOKEN" ]; then
            sed -i "s/tu_token_de_ngrok_aqui/${NGROK_TOKEN}/" .env
            echo -e "${GREEN}✓ NGROK_AUTHTOKEN configurado${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Continuando sin ngrok. Puedes configurarlo después en .env${NC}"
    fi
fi

# Levantar infraestructura
echo -e "${YELLOW}🚀 Levantando infraestructura Docker...${NC}"
echo -e "${BLUE}   (El frontend se compilará automáticamente durante el build)${NC}"
make up
echo ""

# Dar tiempo a que los servicios se inicien
echo -e "${YELLOW}⏳ Esperando a que los servicios estén listos (45s)...${NC}"
sleep 45

# Resumen final
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✅ Instalación completada exitosamente                    ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📍 Servicios disponibles:${NC}"
echo -e "   ${YELLOW}• Aplicación Web:${NC}     http://localhost"
echo -e "   ${YELLOW}• API Backend:${NC}        http://localhost/api"
echo -e "   ${YELLOW}• Portainer:${NC}          http://localhost:9443"
echo -e "   ${YELLOW}• ngrok Dashboard:${NC}    http://localhost:4040"
echo -e "   ${YELLOW}• PostgreSQL:${NC}         localhost:5432"
echo ""
echo -e "${BLUE}👤 Usuario administrador:${NC}"
echo -e "   ${YELLOW}• Email:${NC}      admin@llaves.com"
echo -e "   ${YELLOW}• Contraseña:${NC} test123"
echo -e "   ${RED}⚠️  Cambia esta contraseña después del primer login${NC}"
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
