# 🚀 Pasos para Desplegar el Proyecto

## 📋 Requisitos Previos

```powershell
# Verificar que Docker está instalado
docker --version
docker compose version

# Verificar que Make está disponible (en Windows con Git Bash o WSL)
make --version
```

## 🔧 Paso 1: Configurar Variables de Entorno

```powershell
# Editar el archivo .env
notepad .env

# CONFIGURAR OBLIGATORIAMENTE:
# 1. NGROK_AUTHTOKEN - Obtener en: https://dashboard.ngrok.com/get-started/your-authtoken
# 2. Cambiar contraseñas por seguridad (opcional pero recomendado):
#    - POSTGRES_PASSWORD
#    - APP_SECRET (generar con: openssl rand -hex 32)
#    - JWT_PASSPHRASE (generar con: openssl rand -base64 32)
```

**Obtener token de ngrok:**
1. Crear cuenta gratuita en https://ngrok.com
2. Ir a https://dashboard.ngrok.com/get-started/your-authtoken
3. Copiar el token y pegarlo en `NGROK_AUTHTOKEN=tu_token_aqui`

## 📦 Paso 2: Compilar el Frontend

```powershell
# Ir al directorio del frontend
cd frontend

# Instalar dependencias (solo primera vez)
npm install

# Compilar para producción
npm run build

# Volver al directorio raíz
cd ..
```

**Resultado:** Se creará la carpeta `frontend/dist/` con la aplicación compilada.

## 🐳 Paso 3: Levantar la Infraestructura

```powershell
# Levantar todos los servicios
make up

# O si no tienes Make en Windows:
docker compose -f compose.yml up -d
```

**Servicios que se levantarán:**
- db (PostgreSQL)
- backend (Symfony)
- webserver (Nginx)
- portainer (Gestión)
- ngrok (Túnel público)

## ⏳ Paso 4: Esperar a que los Servicios Estén Listos

```powershell
# Ver el estado de los contenedores
make ps

# O sin Make:
docker compose ps
```

**Espera ~30-60 segundos** para que PostgreSQL esté "healthy" y el backend termine de inicializarse.

## 🗄️ Paso 5: Instalar Dependencias y Ejecutar Migraciones

```powershell
# Instalar dependencias de Composer
make install

# Ejecutar migraciones de base de datos
make migrate

# O sin Make:
docker compose exec backend composer install
docker compose exec backend php bin/console doctrine:migrations:migrate --no-interaction
```

## ✅ Paso 6: Verificar el Despliegue

### Verificar servicios locales:

```powershell
# 1. Frontend
start http://localhost

# 2. Backend API
start http://localhost/api

# 3. Portainer
start http://localhost:9000

# 4. ngrok Dashboard
start http://localhost:4040
```

### Ver la URL pública de ngrok:

```powershell
make ngrok-url

# O visitar: http://localhost:4040
```

**Tu aplicación estará disponible en una URL como:** `https://abc123.ngrok-free.app`

## 🔍 Paso 7: Validar que Todo Funciona

### Verificar logs:

```powershell
# Ver logs de todos los servicios
make logs

# Ver logs específicos
make logs-backend
make logs-nginx
```

### Probar endpoints:

```powershell
# Probar API localmente
curl http://localhost/api

# Probar desde la URL pública de ngrok
curl https://tu-url.ngrok-free.app/api
```

### Verificar base de datos:

```powershell
# Acceder a PostgreSQL
make shell-db

# Dentro de PostgreSQL:
\dt          # Ver tablas
\q           # Salir
```

---

## 🎯 Resumen en Comandos Rápidos

### Con Make (recomendado):

```powershell
# 1. Configurar entorno
notepad .env  # Añadir NGROK_AUTHTOKEN

# 2. Compilar frontend
cd frontend && npm install && npm run build && cd ..

# 3. Desplegar
make up

# 4. Configurar backend
make install
make migrate

# 5. Ver URL pública
make ngrok-url

# 6. Verificar
make ps
start http://localhost
start http://localhost:4040
```

### Sin Make (comandos directos):

```powershell
# 1. Configurar entorno
notepad .env

# 2. Compilar frontend
cd frontend
npm install
npm run build
cd ..

# 3. Desplegar
docker compose -f compose.yml up -d

# 4. Esperar y configurar backend
timeout 30
docker compose exec backend composer install
docker compose exec backend php bin/console doctrine:migrations:migrate --no-interaction

# 5. Verificar
docker compose ps
start http://localhost
start http://localhost:4040
```

---

## 🔄 Comandos Útiles Durante el Uso

### Gestión de servicios:

```powershell
# Ver estado
make ps

# Ver logs en tiempo real
make logs

# Reiniciar servicios
make restart

# Detener
make down

# Acceder al backend
make shell-backend

# Acceder a la base de datos
make shell-db
```

### Ver información de ngrok:

```powershell
# Ver URL pública
make ngrok-url

# O visitar el dashboard
start http://localhost:4040
```

---

## 🛑 Para Detener los Servicios

```powershell
# Detener todos los servicios
make down

# O sin Make:
docker compose down

# Detener y eliminar volúmenes (⚠️ borra la base de datos)
make clean
# O:
docker compose down -v
```

---

## 🔄 Para Actualizar el Código

### Actualizar Backend:

```powershell
# 1. Modificar código en backend/
# 2. Reiniciar el contenedor
docker compose restart backend

# Si cambiaste dependencias:
make install

# Si añadiste migraciones:
make migrate
```

### Actualizar Frontend:

```powershell
# 1. Modificar código en frontend/src/
# 2. Recompilar
cd frontend
npm run build
cd ..

# 3. Reiniciar nginx
docker compose restart webserver

# 4. Refrescar navegador
```

---

## 🐛 Troubleshooting

### Error: "ngrok invalid authtoken"

```powershell
# Solución:
# 1. Editar .env y verificar NGROK_AUTHTOKEN
notepad .env

# 2. Reiniciar
make down
make up
```

### Error: "Connection refused" a PostgreSQL

```powershell
# Solución:
# 1. Esperar más tiempo (PostgreSQL tarda en iniciar)
docker compose ps  # Verificar que db está "healthy"

# 2. Ver logs
make logs-db

# 3. Si persiste, reiniciar
make restart
```

### Frontend muestra 404

```powershell
# Solución:
# 1. Verificar que frontend está compilado
dir frontend\dist

# 2. Si no existe, compilar
cd frontend
npm run build
cd ..

# 3. Reiniciar nginx
docker compose restart webserver
```

### No funciona desde ngrok (Error CORS)

```powershell
# Verificar configuración CORS
type backend\config\packages\nelmio_cors.yaml

# Debe incluir: ngrok-free.app
# Si no, editar el archivo y añadir:
# allow_origin: ['^https?://(localhost|.*\.ngrok-free\.app)']

# Reiniciar backend
docker compose restart backend
```

### Contenedor no arranca

```powershell
# Ver logs del contenedor problemático
docker compose logs [nombre_servicio]

# Ejemplo:
docker compose logs backend
docker compose logs db
docker compose logs webserver

# Reconstruir imagen si es necesario
docker compose build [nombre_servicio]
docker compose up -d [nombre_servicio]
```

### Error de permisos en volúmenes

```powershell
# En Windows, asegúrate de que Docker Desktop tiene acceso a la unidad
# Abrir Docker Desktop → Settings → Resources → File Sharing
# Añadir la unidad donde está el proyecto
```

---

## 📊 Estado Esperado Después del Despliegue

```
✅ 5 contenedores corriendo:
   - llaves-db (PostgreSQL)      → healthy
   - llaves-backend (Symfony)    → Up
   - llaves-webserver (Nginx)    → Up
   - llaves-portainer            → Up
   - llaves-ngrok                → Up

✅ Puertos abiertos:
   - 80   → Nginx (Frontend + API)
   - 5432 → PostgreSQL
   - 9000 → Portainer
   - 9443 → Portainer HTTPS
   - 4040 → ngrok Dashboard

✅ Servicios accesibles:
   - http://localhost           → Frontend Angular
   - http://localhost/api       → Backend Symfony
   - http://localhost:9000      → Portainer
   - http://localhost:4040      → ngrok Dashboard
   - https://[id].ngrok-free.app → Aplicación pública
```

Para verificar todo esto:

```powershell
# Ver estado de contenedores
docker compose ps

# Verificar puertos en uso
netstat -ano | findstr ":80 :5432 :9000 :4040"

# Probar servicios
curl http://localhost
curl http://localhost/api
```

---

## 🎉 ¡Listo para Usar!

Una vez completados todos los pasos, tu aplicación está desplegada y lista para usar.

**URLs importantes:**
- 🌐 **Local:** http://localhost
- 🌍 **Público:** https://[tu-id].ngrok-free.app
- 📊 **Gestión:** http://localhost:9000 (Portainer)
- 🔧 **Túnel:** http://localhost:4040 (ngrok dashboard)

**Comandos más usados:**
```powershell
make up        # Iniciar
make down      # Detener
make logs      # Ver logs
make ps        # Ver estado
make help      # Ver todos los comandos
```

---

## 📞 Ayuda Adicional

Para más información, consulta:
- [INSTRUCCIONES_PRACTICA.md](INSTRUCCIONES_PRACTICA.md) - Guía completa
- [CHECKLIST_VERIFICACION.md](CHECKLIST_VERIFICACION.md) - Lista de verificación
- [FLUJO_DATOS.md](FLUJO_DATOS.md) - Arquitectura y flujos
- [Makefile](Makefile) - Ver todos los comandos disponibles

O ejecuta:
```powershell
make help
```
