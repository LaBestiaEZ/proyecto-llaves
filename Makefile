# Makefile para gestión de microservicios
# Proyecto: Sistema de Llaves con Angular + Symfony + PostgreSQL + Nginx + Portainer

.PHONY: help up down restart build build-frontend rebuild install migrate logs logs-backend logs-frontend logs-db logs-nginx ps clean shell-backend shell-db ngrok-url portainer-url dev-up dev-down dev-restart dev-logs dev-ps dev-build

# Colores para output
YELLOW := \033[1;33m
GREEN := \033[1;32m
RED := \033[1;31m
NC := \033[0m # No Color

## help: Muestra esta ayuda
help:
	@echo "$(YELLOW)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)  Proyecto Llaves - Comandos Disponibles$(NC)"
	@echo "$(YELLOW)═══════════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(GREEN)Gestión de Contenedores (PRODUCCIÓN):$(NC)"
	@echo "  make up            - Levanta toda la infraestructura en segundo plano"
	@echo "  make down          - Baja todos los servicios"
	@echo "  make restart       - Reinicia todos los servicios"
	@echo "  make build         - Construye las imágenes Docker sin caché"
	@echo "  make rebuild       - Reconstruye TODO desde cero (frontend + docker)"
	@echo "  make ps            - Muestra el estado de los contenedores"
	@echo ""
	@echo "$(GREEN)Gestión de Contenedores (DESARROLLO):$(NC)"
	@echo "  make dev-up        - Levanta entorno de desarrollo (sin portainer/ngrok)"
	@echo "  make dev-down      - Baja entorno de desarrollo"
	@echo "  make dev-restart   - Reinicia entorno de desarrollo"
	@echo "  make dev-build     - Construye imágenes para desarrollo"
	@echo "  make dev-ps        - Estado de contenedores de desarrollo"
	@echo "  make dev-logs      - Logs del entorno de desarrollo"
	@echo ""
	@echo "$(GREEN)Gestión de Dependencias:$(NC)"
	@echo "  make install       - Instala dependencias de Composer (PHP)"
	@echo "  make migrate       - Ejecuta las migraciones de Doctrine"
	@echo ""
	@echo "$(GREEN)Logs:$(NC)"
	@echo "  make logs          - Muestra logs en tiempo real de todos los servicios"
	@echo "  make logs-backend  - Logs del backend Symfony"
	@echo "  make logs-frontend - Logs del frontend Angular"
	@echo "  make logs-db       - Logs de PostgreSQL"
	@echo "  make logs-nginx    - Logs de Nginx"
	@echo ""
	@echo "$(GREEN)Acceso a Contenedores:$(NC)"
	@echo "  make shell-backend - Acceso shell al contenedor backend"
	@echo "  make shell-db      - Acceso shell a PostgreSQL"
	@echo ""
	@echo "$(GREEN)URLs y Utilidades:$(NC)"
	@echo "  make ngrok-url     - Muestra la URL pública de ngrok"
	@echo "  make portainer-url - Muestra la URL de Portainer"
	@echo "  make clean         - Limpia contenedores, volúmenes e imágenes"
	@echo ""
	@echo "$(YELLOW)═══════════════════════════════════════════════════════════════$(NC)"

## up: Levanta toda la infraestructura en segundo plano
up:
	@echo "$(YELLOW)🚀 Levantando infraestructura...$(NC)"
	DOCKER_BUILDKIT=1 docker compose -f compose.yml up -d
	@echo "$(GREEN)✓ Infraestructura levantada correctamente$(NC)"
	@echo ""
	@echo "$(YELLOW)📍 Servicios disponibles:$(NC)"
	@echo "  - Frontend/Backend: http://localhost"
	@echo "  - Portainer: http://localhost:9443"
	@echo "  - ngrok Dashboard: http://localhost:4040"
	@echo "  - PostgreSQL: localhost:5432"
	@echo ""
	@make ps

## down: Baja todos los servicios
down:
	@echo "$(YELLOW)🛑 Deteniendo servicios...$(NC)"
	docker compose -f compose.yml down
	@echo "$(GREEN)✓ Servicios detenidos$(NC)"

## restart: Reinicia todos los servicios
restart: down up

## build: Construye las imágenes Docker
build:
	@echo "$(YELLOW)🔨 Construyendo imágenes...$(NC)"
	DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker compose -f compose.yml build --no-cache
	@echo "$(GREEN)✓ Imágenes construidas$(NC)"

## build-frontend: Compila el frontend de Angular
build-frontend:
	@echo "$(YELLOW)🎨 Verificando frontend...$(NC)"
	@if [ ! -d "frontend/dist" ] || [ -z "$$(ls -A frontend/dist 2>/dev/null)" ]; then \
		echo "$(YELLOW)📦 Compilando frontend Angular...$(NC)"; \
		if [ ! -d "frontend/node_modules" ]; then \
			echo "$(YELLOW)   Instalando dependencias npm...$(NC)"; \
			cd frontend && npm install && cd ..; \
		fi; \
		echo "$(YELLOW)   Compilando para producción...$(NC)"; \
		cd frontend && npm run build && cd ..; \
		echo "$(GREEN)✓ Frontend compilado$(NC)"; \
	else \
		echo "$(GREEN)✓ Frontend ya está compilado$(NC)"; \
	fi

## rebuild: Reconstruye TODO desde cero (frontend + imágenes Docker)
rebuild:
	@echo "$(YELLOW)🔥 Reconstruyendo TODO desde cero...$(NC)"
	@echo "$(YELLOW)   Bajando contenedores...$(NC)"
	@docker compose -f compose.yml down -v
	@echo "$(YELLOW)   Limpiando caché de Docker...$(NC)"
	@DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker compose -f compose.yml build --no-cache
	@echo "$(YELLOW)   Levantando servicios...$(NC)"
	@DOCKER_BUILDKIT=1 docker compose -f compose.yml up -d
	@echo "$(GREEN)✓ Reconstrucción completa terminada$(NC)"
	@echo ""
	@make ps

## install: Instala dependencias de Composer dentro del contenedor backend
install:
	@echo "$(YELLOW)📦 Instalando dependencias de Composer...$(NC)"
	docker compose -f compose.yml exec backend composer install
	@echo "$(GREEN)✓ Dependencias instaladas$(NC)"

## migrate: Ejecuta las migraciones de Doctrine
migrate:
	@echo "$(YELLOW)🗄️  Ejecutando migraciones de Doctrine...$(NC)"
	docker compose -f compose.yml exec backend php bin/console doctrine:migrations:migrate --no-interaction
	@echo "$(GREEN)✓ Migraciones ejecutadas$(NC)"

## logs: Muestra logs en tiempo real de todos los servicios
logs:
	@echo "$(YELLOW)📋 Mostrando logs (Ctrl+C para salir)...$(NC)"
	docker compose -f compose.yml logs -f

## logs-backend: Logs del backend Symfony
logs-backend:
	@echo "$(YELLOW)📋 Logs del Backend...$(NC)"
	docker compose -f compose.yml logs -f backend

## logs-frontend: Logs del frontend (a través de nginx)
logs-frontend:
	@echo "$(YELLOW)📋 Logs del Frontend (Nginx)...$(NC)"
	docker compose -f compose.yml logs -f webserver

## logs-db: Logs de PostgreSQL
logs-db:
	@echo "$(YELLOW)📋 Logs de PostgreSQL...$(NC)"
	docker compose -f compose.yml logs -f db

## logs-nginx: Logs de Nginx
logs-nginx:
	@echo "$(YELLOW)📋 Logs de Nginx...$(NC)"
	docker compose -f compose.yml logs -f webserver

## ps: Muestra el estado de los contenedores
ps:
	@echo "$(YELLOW)📊 Estado de los contenedores:$(NC)"
	@docker compose -f compose.yml ps

## shell-backend: Acceso shell al contenedor backend
shell-backend:
	@echo "$(YELLOW)🐚 Accediendo al contenedor backend...$(NC)"
	docker compose -f compose.yml exec backend /bin/sh

## shell-db: Acceso shell a PostgreSQL
shell-db:
	@echo "$(YELLOW)🐚 Accediendo a PostgreSQL...$(NC)"
	docker compose -f compose.yml exec db psql -U $${POSTGRES_USER:-llaves_user} -d $${POSTGRES_DB:-llaves_db}

## ngrok-url: Muestra la URL pública de ngrok
ngrok-url:
	@echo "$(YELLOW)🌐 Obteniendo URL pública de ngrok...$(NC)"
	@echo "$(GREEN)Visita: http://localhost:4040 para ver la URL de ngrok$(NC)"
	@curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -o '"public_url":"[^"]*"' | head -1 || echo "$(RED)ngrok no está ejecutándose o no hay túneles activos$(NC)"

## portainer-url: Muestra la URL de Portainer
portainer-url:
	@echo "$(YELLOW)🎛️  Portainer disponible en:$(NC)"
	@echo "$(GREEN)http://localhost:9000$(NC)"

## clean: Limpia contenedores, volúmenes e imágenes
clean:
	@echo "$(RED)⚠️  ¿Estás seguro de eliminar TODOS los contenedores, volúmenes e imágenes? [y/N]$(NC)"
	@read -p "" confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "$(YELLOW)🧹 Limpiando producción...$(NC)"; \
		docker compose -f compose.yml down -v --remove-orphans; \
		echo "$(YELLOW)🧹 Limpiando desarrollo...$(NC)"; \
		docker compose -f compose.dev.yml down -v --remove-orphans 2>/dev/null || true; \
		echo "$(YELLOW)🧹 Eliminando imágenes del proyecto...$(NC)"; \
		docker images | grep proyecto-llaves | awk '{print $$3}' | xargs -r docker rmi -f 2>/dev/null || true; \
		docker images | grep llaves-frontend-builder | awk '{print $$3}' | xargs -r docker rmi -f 2>/dev/null || true; \
		echo "$(YELLOW)🧹 Limpiando volúmenes huérfanos...$(NC)"; \
		docker volume prune -f; \
		echo "$(GREEN)✓ Limpieza completa terminada$(NC)"; \
	else \
		echo "$(YELLOW)Operación cancelada$(NC)"; \
	fi

# ============================================================================
# COMANDOS DE DESARROLLO (compose.dev.yml)
# ============================================================================

## dev-up: Levanta entorno de desarrollo (sin portainer/ngrok)
dev-up:
	@echo "$(YELLOW)🚀 Levantando entorno de DESARROLLO...$(NC)"
	DOCKER_BUILDKIT=1 docker compose -f compose.dev.yml up -d
	@echo "$(GREEN)✓ Entorno de desarrollo levantado$(NC)"
	@echo ""
	@echo "$(YELLOW)📍 Servicios disponibles:$(NC)"
	@echo "  - Frontend (dev): http://localhost:4200"
	@echo "  - Backend API: http://localhost:8080/api"
	@echo "  - PostgreSQL: localhost:5432"
	@echo ""
	@make dev-ps

## dev-down: Baja entorno de desarrollo
dev-down:
	@echo "$(YELLOW)🛑 Deteniendo entorno de desarrollo...$(NC)"
	docker compose -f compose.dev.yml down
	@echo "$(GREEN)✓ Entorno de desarrollo detenido$(NC)"

## dev-restart: Reinicia entorno de desarrollo
dev-restart: dev-down dev-up

## dev-build: Construye las imágenes para desarrollo
dev-build:
	@echo "$(YELLOW)🔨 Construyendo imágenes de desarrollo...$(NC)"
	DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker compose -f compose.dev.yml build --no-cache
	@echo "$(GREEN)✓ Imágenes de desarrollo construidas$(NC)"

## dev-ps: Muestra el estado de los contenedores de desarrollo
dev-ps:
	@echo "$(YELLOW)📊 Estado de los contenedores de desarrollo:$(NC)"
	@docker compose -f compose.dev.yml ps

## dev-logs: Muestra logs del entorno de desarrollo
dev-logs:
	@echo "$(YELLOW)📋 Mostrando logs de desarrollo (Ctrl+C para salir)...$(NC)"
	docker compose -f compose.dev.yml logs -f

## dev-logs-backend: Logs del backend en desarrollo
dev-logs-backend:
	@echo "$(YELLOW)📋 Logs del Backend (desarrollo)...$(NC)"
	docker compose -f compose.dev.yml logs -f backend

## dev-logs-frontend: Logs del frontend en desarrollo
dev-logs-frontend:
	@echo "$(YELLOW)📋 Logs del Frontend (desarrollo)...$(NC)"
	docker compose -f compose.dev.yml logs -f frontend

## dev-install: Instala dependencias en modo desarrollo
dev-install:
	@echo "$(YELLOW)📦 Instalando dependencias de desarrollo...$(NC)"
	docker compose -f compose.dev.yml exec backend composer install
	@echo "$(GREEN)✓ Dependencias de desarrollo instaladas$(NC)"

## dev-migrate: Ejecuta migraciones en modo desarrollo
dev-migrate:
	@echo "$(YELLOW)🗄️  Ejecutando migraciones (desarrollo)...$(NC)"
	docker compose -f compose.dev.yml exec backend php bin/console doctrine:migrations:migrate --no-interaction
	@echo "$(GREEN)✓ Migraciones ejecutadas$(NC)"

## dev-shell-backend: Acceso shell al backend en desarrollo
dev-shell-backend:
	@echo "$(YELLOW)🐚 Accediendo al contenedor backend (desarrollo)...$(NC)"
	docker compose -f compose.dev.yml exec backend /bin/sh

## dev-shell-db: Acceso shell a PostgreSQL en desarrollo
dev-shell-db:
	@echo "$(YELLOW)🐚 Accediendo a PostgreSQL (desarrollo)...$(NC)"
	docker compose -f compose.dev.yml exec db psql -U $${POSTGRES_USER:-llaves_user} -d $${POSTGRES_DB:-llaves_db}

## dev-clean: Limpia contenedores y volúmenes de desarrollo
dev-clean:
	@echo "$(RED)⚠️  ¿Eliminar contenedores y volúmenes de desarrollo? [y/N]$(NC)"
	@read -p "" confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "$(YELLOW)🧹 Limpiando entorno de desarrollo...$(NC)"; \
		docker compose -f compose.dev.yml down -v; \
		echo "$(GREEN)✓ Limpieza de desarrollo completada$(NC)"; \
	else \
		echo "$(YELLOW)Operación cancelada$(NC)"; \
	fi

# Comando por defecto
.DEFAULT_GOAL := help
