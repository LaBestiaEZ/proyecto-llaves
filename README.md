# Proyecto Llaves - Symfony API + Angular

Sistema con backend en Symfony (API REST) y frontend en Angular, todo dockerizado para desarrollo y producción.

## 📋 Requisitos

- Docker Desktop para Windows
- Git
- (Opcional) Composer y PHP 8.3+ para desarrollo local
- (Opcional) Node.js 20+ para desarrollo local

## 🚀 Pasos de Instalación

### 1. Crear el proyecto Symfony

```powershell
cd backend
composer create-project symfony/skeleton:"7.1.*" .
composer require api
composer require symfony/orm-pack
composer require --dev symfony/maker-bundle
composer require nelmio/cors-bundle
```

### 2. Crear el proyecto Angular

```powershell
cd ../frontend
npx @angular/cli@latest new . --skip-git=true --routing --style=scss
```

### 3. Configurar CORS en Symfony

Editar `backend/config/packages/nelmio_cors.yaml`:

```yaml
nelmio_cors:
    defaults:
        origin_regex: true
        allow_origin: ['http://localhost:4200']
        allow_methods: ['GET', 'OPTIONS', 'POST', 'PUT', 'PATCH', 'DELETE']
        allow_headers: ['Content-Type', 'Authorization']
        expose_headers: ['Link']
        max_age: 3600
    paths:
        '^/api': ~
```

### 4. Levantar el entorno con Docker

```powershell
# Desarrollo
docker-compose up -d

# Producción
docker-compose -f docker-compose.prod.yml up -d
```

## 🐳 Servicios Docker

| Servicio | Puerto | URL |
|----------|--------|-----|
| Frontend (Angular) | 4200 | http://localhost:4200 |
| Backend API (Symfony) | 8080 | http://localhost:8080 |
| PostgreSQL | 5432 | localhost:5432 |

## 📦 Comandos Útiles

### Symfony

```powershell
# Crear entidad
docker-compose exec php bin/console make:entity

# Migraciones
docker-compose exec php bin/console make:migration
docker-compose exec php bin/console doctrine:migrations:migrate

# Crear controlador API
docker-compose exec php bin/console make:controller --api
```

### Angular

```powershell
# Generar componente
docker-compose exec frontend ng generate component nombre

# Generar servicio
docker-compose exec frontend ng generate service services/nombre
```

### Base de datos

```powershell
# Acceder a PostgreSQL
docker-compose exec db psql -U llaves_user -d llaves_db
```

## 🔧 Desarrollo

1. **Backend**: El código está en `/backend` y se sincroniza automáticamente
2. **Frontend**: El código está en `/frontend` con hot-reload habilitado
3. **Base de datos**: Los datos persisten en un volumen Docker

## 🚢 Despliegue a Producción

1. Copiar `.env.example` a `.env` y configurar variables
2. Ejecutar: `docker-compose -f docker-compose.prod.yml up -d --build`
3. Configurar dominio y SSL (recomendado usar Nginx Proxy Manager o Traefik)

## 📝 Estructura del Proyecto

```
proyecto-llaves/
├── backend/              # API Symfony
│   ├── src/
│   ├── config/
│   └── public/
├── frontend/             # App Angular
│   ├── src/
│   └── angular.json
├── docker/               # Configuración Docker
│   ├── php/
│   ├── nginx/
│   └── angular/
├── docker-compose.yml    # Desarrollo
└── docker-compose.prod.yml  # Producción
```

## 🛠️ Solución de Problemas

### Error de permisos en backend
```powershell
docker-compose exec php chown -R www-data:www-data /var/www/backend
```

### Reinstalar dependencias
```powershell
docker-compose down
docker-compose up -d --build
```

## 📄 Licencia

Este proyecto es privado.
