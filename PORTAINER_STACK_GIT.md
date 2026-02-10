# 🐳 Despliegue con Portainer Stack desde Git

## 📋 ¿Qué es Portainer Stack?

Portainer permite crear **Stacks** directamente desde un repositorio Git, lo que te permite:
- ✅ Desplegar con un solo click
- ✅ Actualizar automáticamente desde Git
- ✅ Gestionar variables de entorno desde la interfaz
- ✅ Tener control visual del despliegue

## 🚀 Pasos para Desplegar

### 1️⃣ Acceder a Portainer

```powershell
# Levantar solo Portainer (si no está corriendo)
docker run -d -p 9000:9000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

# Abrir en navegador
start http://localhost:9000
```

**Primera vez:**
1. Crear usuario administrador
2. Seleccionar "Docker" como entorno
3. Conectar al Docker local

---

### 2️⃣ Crear Stack desde Git

**En Portainer:**

1. **Ir a "Stacks"** (menú lateral)
2. **Click en "+ Add stack"**
3. **Configurar:**

   - **Name:** `proyecto-llaves`
   
   - **Build method:** Seleccionar **"Repository"**
   
   - **Repository URL:**
     ```
     https://github.com/LaBestiaEZ/proyecto-llaves
     ```
   
   - **Repository reference:** `refs/heads/practica-despliegue`
   
   - **Compose path:** `compose.portainer.yml`
   
   ⚠️ **IMPORTANTE:** Usar `compose.portainer.yml` (sin el servicio portainer, para evitar recursión)
   
   - **Authentication:** 
     - Si el repo es público: dejar en blanco
     - Si es privado: añadir token de GitHub

4. **Variables de Entorno:**

   Click en **"Add an environment variable"** y añadir:

   ```bash
   POSTGRES_DB=llaves_produccion
   POSTGRES_USER=llaves_user
   POSTGRES_PASSWORD=tu_password_seguro_aqui
   DB_PORT=5432
   
   APP_ENV=prod
   APP_SECRET=tu_secret_de_32_caracteres
   APP_DEBUG=0
   
   JWT_PASSPHRASE=tu_passphrase_seguro
   JWT_TTL=3600
   
   CORS_ALLOW_ORIGIN=^https?://(localhost|127\.0\.0\.1|.*\.ngrok-free\.app)(:[0-9]+)?$
   
   WEBSERVER_PORT=80
   PORTAINER_PORT=9000
   PORTAINER_HTTPS_PORT=9443
   NGROK_PORT=4040
   
   NGROK_AUTHTOKEN=tu_token_de_ngrok
   NGROK_DOMAIN=
   ```

5. **Deploy the stack** → Click en el botón azul

---

### 3️⃣ Monitorear el Despliegue

Portainer te mostrará:
- ✅ Contenedores que se están creando
- ✅ Logs en tiempo real
- ✅ Estado de cada servicio
- ✅ Recursos utilizados

**Acceder a logs:**
1. Ir a "Containers"
2. Click en el contenedor
3. Ver "Logs" en tiempo real

---

### 4️⃣ Verificar Despliegue

Una vez desplegado:

```
✅ Frontend: http://localhost
✅ Backend API: http://localhost/api
✅ Portainer: http://localhost:9000
✅ ngrok: http://localhost:4040
✅ PostgreSQL: localhost:5432
```

---

## 🔄 Actualizar Stack desde Git

Cuando hagas cambios en el repositorio:

1. **Manual:**
   - Ir al Stack en Portainer
   - Click en **"Pull and redeploy"**
   - Confirmar

2. **Automático (webhooks):**
   - En la configuración del Stack
   - Activar **"Enable webhook"**
   - Copiar la URL del webhook
   - Configurar en GitHub (Settings → Webhooks)

---

## ⚙️ Archivo compose.yml Optimizado para Portainer

**Nota:** El `compose.yml` actual ya está optimizado para Portainer. Solo asegúrate de:

### ✅ Variables de Entorno

Todas las variables deben estar parametrizadas con `${VARIABLE}`:

```yaml
environment:
  POSTGRES_DB: ${POSTGRES_DB}
  POSTGRES_USER: ${POSTGRES_USER}
  # etc...
```

✅ **Ya está hecho en tu compose.yml**

### ✅ Volúmenes Nombrados

```yaml
volumes:
  postgres_data:
    driver: local
  portainer_data:
    driver: local
```

✅ **Ya está configurado**

### ✅ Redes

```yaml
networks:
  llaves-network:
    driver: bridge
```

✅ **Ya está configurado**

---

## 🔐 Gestión de Secretos en Portainer

### Opción 1: Variables de Entorno (Actual)

Configurar en la UI de Portainer al crear el Stack.

**Ventajas:**
- ✅ Fácil de configurar
- ✅ Visible en la interfaz
- ⚠️ No encriptado (visible para admins)

### Opción 2: Docker Secrets (Avanzado)

Si quieres mayor seguridad:

1. **Crear secrets en Portainer:**
   - Ir a "Secrets"
   - Crear: `db_password`, `jwt_passphrase`, etc.

2. **Modificar compose.yml:**

```yaml
services:
  db:
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    external: true
```

---

## 📦 Preparar el Proyecto para Portainer

### 1. Frontend Compilado

**Opción A: Compilar localmente y subir dist/**

```powershell
# Compilar
cd frontend
npm run build
cd ..

# Subir a Git (añadir dist/ al repo)
git add frontend/dist
git commit -m "Add: Frontend compilado para Portainer"
git push
```

**Modificar .gitignore:**
```bash
# Comentar esta línea:
# /frontend/dist/
```

**Opción B: Build multietapa en Dockerfile**

Crear `docker/nginx/Dockerfile.frontend`:

```dockerfile
FROM node:20-alpine as build
WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci
COPY frontend .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist/frontend/browser /usr/share/nginx/html
COPY docker/nginx/nginx.prod.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

Modificar `compose.yml`:

```yaml
webserver:
  build:
    context: .
    dockerfile: docker/nginx/Dockerfile.frontend
  # resto igual...
```

---

## 🎯 Flujo Completo con Portainer

### Desarrollo Local

```powershell
# Trabajar localmente
make dev-up

# Hacer cambios...
# Probar...

# Commitear y push
git add .
git commit -m "feat: Nueva funcionalidad"
git push origin practica-despliegue
```

### Despliegue en Portainer

1. **Ir a Portainer**
2. **Click en el Stack "proyecto-llaves"**
3. **Click en "Pull and redeploy"**
4. **Esperar ~30 segundos**
5. **Verificar en navegador**

---

## 🔍 Troubleshooting en Portainer

### Stack falla al desplegar

**Ver logs:**
1. Ir a la vista del Stack
2. Ver la sección "Events"
3. Identificar qué contenedor falló
4. Ir al contenedor específico → Logs

**Errores comunes:**

**1. Variables de entorno faltantes**
```
Error: environment variable "NGROK_AUTHTOKEN" is not set
```
**Solución:** Añadir la variable en la configuración del Stack

**2. Puerto en uso**
```
Error: bind: address already in use
```
**Solución:** Cambiar el puerto en las variables de entorno

**3. Volúmenes con permisos**
```
Error: permission denied
```
**Solución:** En stack settings, activar "Enable access control"

### Actualizar variables de entorno

1. Ir al Stack
2. Click en "Editor" (arriba)
3. Editar las variables abajo
4. Click "Update the stack"

---

## 🌐 Exponer con ngrok desde Portainer

El contenedor de ngrok se levantará automáticamente con el Stack.

**Ver URL pública:**

1. **Opción 1:** Navegador
   ```
   http://localhost:4040
   ```

2. **Opción 2:** Logs en Portainer
   - Ir al contenedor `llaves-ngrok`
   - Ver logs
   - Buscar la línea con la URL pública

3. **Opción 3:** Ejecutar comando
   - En Portainer, ir al contenedor `llaves-ngrok`
   - Click en "Console"
   - Seleccionar `/bin/sh`
   - Ejecutar:
     ```sh
     wget -qO- http://localhost:4040/api/tunnels | grep public_url
     ```

---

## 📊 Ventajas de usar Portainer Stack

| Característica | Sin Portainer | Con Portainer Stack |
|----------------|---------------|---------------------|
| **Despliegue** | Terminal/SSH | Click en interfaz |
| **Actualización** | `git pull` + `docker compose up` | Click "Pull & redeploy" |
| **Variables** | Archivo .env | Interfaz visual |
| **Logs** | `docker compose logs` | Interfaz visual en tiempo real |
| **Monitoreo** | `docker stats` | Dashboard con gráficos |
| **Rollback** | Manual | Click en versión anterior |
| **Multi-servidor** | Repetir en cada uno | Un Stack para todos |

---

## 🎓 Comandos Útiles en Portainer

### Desde la Consola del Contenedor

**Backend (Symfony):**
```sh
# Acceder a la consola del contenedor backend
composer install
php bin/console doctrine:migrations:migrate
php bin/console cache:clear
php bin/console app:create-admin
```

**Base de Datos:**
```sh
# Acceder a PostgreSQL
psql -U llaves_user -d llaves_produccion
```

**Ejecutar desde Portainer:**
1. Ir al contenedor
2. Click en "Console"
3. Seleccionar shell (`/bin/sh` o `/bin/bash`)
4. Ejecutar comandos

---

## 🔒 Mejores Prácticas

### ✅ DO (Hacer)

- ✅ Usar variables de entorno para configuración
- ✅ Subir compose.yml al repositorio
- ✅ Mantener .env.example actualizado
- ✅ Usar tags específicos de imágenes (no `latest` en prod)
- ✅ Configurar healthchecks en servicios
- ✅ Usar volúmenes nombrados para persistencia

### ❌ DON'T (No Hacer)

- ❌ Subir archivo .env con credenciales reales
- ❌ Hardcodear contraseñas en compose.yml
- ❌ Exponer puertos innecesarios
- ❌ Usar `restart: always` en desarrollo
- ❌ Ignorar los logs de errores

---

## 🎯 Checklist de Despliegue con Portainer

Antes de desplegar:

```
[ ] compose.yml en el repositorio
[ ] Variables parametrizadas con ${VAR}
[ ] Frontend compilado (si Opción A)
[ ] .gitignore actualizado
[ ] Push a rama practica-despliegue
[ ] Token de ngrok obtenido
[ ] Contraseñas seguras generadas
```

Durante el despliegue:

```
[ ] Portainer accesible en :9000
[ ] Stack creado con nombre descriptivo
[ ] URL del repo correcta
[ ] Rama correcta (practica-despliegue)
[ ] Todas las variables de entorno configuradas
[ ] Deploy exitoso sin errores
```

Después del despliegue:

```
[ ] Todos los contenedores "running"
[ ] Frontend accesible en http://localhost
[ ] Backend API responde en http://localhost/api
[ ] ngrok genera URL pública
[ ] Base de datos acepta conexiones
[ ] Logs sin errores críticos
```

---

## 🚀 Conclusión

Portainer Stack hace que el despliegue sea:
- 🎯 **Visual:** Todo controlado desde la interfaz
- 🔄 **Automatizado:** Un click para actualizar
- 📊 **Monitorizado:** Dashboard con métricas en tiempo real
- 🔒 **Seguro:** Variables de entorno centralizadas
- 👥 **Colaborativo:** Múltiples usuarios pueden gestionar

¡Perfecto para presentar la práctica de forma profesional! 🎉
