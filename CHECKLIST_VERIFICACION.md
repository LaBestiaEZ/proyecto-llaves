# ✅ Checklist de Verificación Final

## 📋 Antes de Entregar

### 1. Configuración de Archivos

- [ ] **`.env` creado y configurado** (NO subir a Git)
  ```bash
  test -f .env && echo "✅ Existe" || echo "❌ No existe"
  ```

- [ ] **`.env.example` presente** (SÍ subir a Git)
  ```bash
  test -f .env.example && echo "✅ Existe" || echo "❌ No existe"
  ```

- [ ] **`.gitignore` incluye `.env`**
  ```bash
  grep -q "^\.env$" .gitignore && echo "✅ Configurado" || echo "❌ NO configurado"
  ```

- [ ] **`NGROK_AUTHTOKEN` configurado en `.env`**
  ```bash
  grep -q "NGROK_AUTHTOKEN=.*[a-zA-Z0-9]" .env && echo "✅ Configurado" || echo "❌ Falta configurar"
  ```

- [ ] **Contraseñas cambiadas de los valores por defecto**
  ```bash
  # Verificar que no tengas "changeme" o "password" en producción
  grep -E "(changeme|password_seguro_aqui)" .env && echo "❌ Cambiar contraseñas" || echo "✅ OK"
  ```

---

### 2. Estructura de Archivos Requeridos

- [ ] **`compose.yml`** - Orquestación de microservicios
  - [ ] Servicio `db` (PostgreSQL)
  - [ ] Servicio `backend` (PHP-FPM)
  - [ ] Servicio `webserver` (Nginx)
  - [ ] Servicio `portainer`
  - [ ] Servicio `ngrok`
  - [ ] Red `llaves-network`
  - [ ] Volúmenes `postgres_data` y `portainer_data`

  ```bash
  # Verificar estructura
  docker compose config --quiet && echo "✅ compose.yml válido" || echo "❌ Errores en compose.yml"
  ```

- [ ] **`Makefile`** - Comandos de gestión
  - [ ] `make up`
  - [ ] `make down`
  - [ ] `make migrate`
  - [ ] `make install`
  - [ ] `make logs`
  - [ ] `make help`

  ```bash
  # Verificar comandos
  grep -E "(^up:|^down:|^migrate:|^install:|^logs:)" Makefile && echo "✅ Comandos presentes"
  ```

- [ ] **`docker/nginx/nginx.prod.conf`** - Configuración de Nginx como proxy
  ```bash
  grep -q "location /api" docker/nginx/nginx.prod.conf && echo "✅ Proxy configurado" || echo "❌ Falta configuración"
  ```

- [ ] **`backend/config/packages/nelmio_cors.yaml`** - CORS configurado
  ```bash
  grep -q "ngrok" backend/config/packages/nelmio_cors.yaml && echo "✅ CORS con ngrok" || echo "⚠️  Verificar CORS"
  ```

---

### 3. Frontend Compilado

- [ ] **Dependencias instaladas**
  ```bash
  test -d frontend/node_modules && echo "✅ node_modules existe" || echo "❌ Ejecutar: cd frontend && npm install"
  ```

- [ ] **Aplicación compilada**
  ```bash
  test -d frontend/dist && echo "✅ Frontend compilado" || echo "❌ Ejecutar: cd frontend && npm run build"
  ```

- [ ] **URLs actualizadas en environments**
  ```bash
  grep -q "apiUrl.*'/api'" frontend/src/environments/environment.prod.ts && echo "✅ URL relativa configurada" || echo "⚠️  Verificar environment"
  ```

---

### 4. Funcionamiento de Servicios

- [ ] **Levantar infraestructura**
  ```bash
  make up
  ```

- [ ] **Todos los contenedores en ejecución**
  ```bash
  docker compose ps
  # Debe mostrar 5 contenedores: db, backend, webserver, portainer, ngrok
  ```

- [ ] **PostgreSQL healthy**
  ```bash
  docker compose exec db pg_isready -U llaves_user && echo "✅ PostgreSQL OK" || echo "❌ PostgreSQL no responde"
  ```

- [ ] **Backend responde**
  ```bash
  curl -s http://localhost/api | grep -q "hydra:member\|@context" && echo "✅ Backend OK" || echo "⚠️  Verificar backend"
  ```

- [ ] **Frontend accesible**
  ```bash
  curl -s http://localhost | grep -q "<title>" && echo "✅ Frontend OK" || echo "❌ Frontend no responde"
  ```

- [ ] **Portainer accesible**
  ```bash
  curl -s http://localhost:9000 | grep -q "Portainer" && echo "✅ Portainer OK" || echo "❌ Portainer no responde"
  ```

- [ ] **ngrok Dashboard accesible**
  ```bash
  curl -s http://localhost:4040 | grep -q "ngrok" && echo "✅ ngrok OK" || echo "❌ ngrok no responde"
  ```

---

### 5. Funcionalidad de Makefile

- [ ] **`make up` levanta servicios**
  ```bash
  make up
  # Debe ejecutarse sin errores
  ```

- [ ] **`make down` detiene servicios**
  ```bash
  make down
  make ps # No debe mostrar contenedores corriendo
  ```

- [ ] **`make install` ejecuta composer**
  ```bash
  make up
  make install
  # Debe instalar dependencias de Composer
  ```

- [ ] **`make migrate` ejecuta migraciones**
  ```bash
  make migrate
  # Debe ejecutar migraciones de Doctrine
  ```

- [ ] **`make logs` muestra logs**
  ```bash
  timeout 5 make logs | head -20
  # Debe mostrar logs de contenedores
  ```

- [ ] **`make help` muestra ayuda**
  ```bash
  make help | grep -q "Comandos Disponibles" && echo "✅ Ayuda OK"
  ```

---

### 6. Exposición Pública con ngrok

- [ ] **ngrok arrancado**
  ```bash
  docker compose ps | grep ngrok | grep -q "Up" && echo "✅ ngrok corriendo"
  ```

- [ ] **Dashboard ngrok funciona**
  ```bash
  curl -s http://localhost:4040/api/tunnels | grep -q "public_url" && echo "✅ Túnel activo" || echo "❌ Túnel no activo"
  ```

- [ ] **Obtener URL pública**
  ```bash
  make ngrok-url
  # O visitar http://localhost:4040
  ```

- [ ] **URL pública accesible desde internet**
  ```bash
  # Copiar URL de ngrok y probar desde navegador o:
  # curl https://tu-url.ngrok-free.app
  ```

- [ ] **API funciona desde ngrok**
  ```bash
  # Reemplazar con tu URL de ngrok
  curl -s https://tu-url.ngrok-free.app/api | grep -q "hydra:member" && echo "✅ API pública OK"
  ```

- [ ] **CORS permite peticiones desde ngrok**
  ```bash
  # Desde el frontend en ngrok, hacer petición a /api
  # No debe haber errores de CORS en consola del navegador
  ```

---

### 7. Base de Datos y Migraciones

- [ ] **Migraciones ejecutadas**
  ```bash
  make shell-backend
  php bin/console doctrine:migrations:list
  # Todas las migraciones deben estar ejecutadas
  exit
  ```

- [ ] **Tablas creadas**
  ```bash
  make shell-db
  \dt
  # Debe mostrar: users, products, orders, appointments, faqs, etc.
  \q
  ```

- [ ] **Datos de prueba creados (opcional)**
  ```bash
  make shell-backend
  php bin/console app:create-sample-data
  exit
  ```

---

### 8. Seguridad y Buenas Prácticas

- [ ] **`.env` NO está en Git**
  ```bash
  git status .env 2>&1 | grep -q "Untracked\|not staged" && echo "❌ .env no debe estar en staging" || echo "✅ .env ignorado"
  ```

- [ ] **`.env.example` SÍ está en Git**
  ```bash
  git ls-files | grep -q ".env.example" && echo "✅ .env.example en Git" || echo "❌ Añadir .env.example"
  ```

- [ ] **No hay credenciales hardcodeadas en código**
  ```bash
  grep -r "password.*=" backend/src --include="*.php" | grep -v "password'" && echo "⚠️  Verificar credenciales hardcodeadas" || echo "✅ No hay credenciales en código"
  ```

- [ ] **JWT keys generadas**
  ```bash
  test -f backend/config/jwt/private.pem && echo "✅ JWT keys OK" || echo "⚠️  Generar JWT keys"
  ```

---

### 9. Documentación

- [ ] **README.md o INSTRUCCIONES_PRACTICA.md**
  ```bash
  test -f INSTRUCCIONES_PRACTICA.md && echo "✅ Documentación presente"
  ```

- [ ] Incluye:
  - [ ] Instrucciones de instalación
  - [ ] Configuración de variables de entorno
  - [ ] Comandos del Makefile
  - [ ] URLs de acceso a servicios
  - [ ] Troubleshooting

---

### 10. Limpieza Final

- [ ] **No hay archivos temporales**
  ```bash
  # Limpiar archivos de caché, logs innecesarios
  find . -name ".DS_Store" -delete
  find . -name "Thumbs.db" -delete
  ```

- [ ] **Volúmenes de Docker no ocupan espacio innecesario**
  ```bash
  docker system df
  # Verificar que no hay volúmenes huérfanos
  ```

---

## 🚀 Script de Verificación Automática

Ejecuta este script para verificar todo automáticamente:

```bash
#!/bin/bash

echo "🔍 Verificación Automática de la Práctica"
echo "=========================================="
echo ""

errors=0

# 1. Archivos de configuración
echo "📁 Verificando archivos de configuración..."
[ -f .env ] && echo "  ✅ .env existe" || { echo "  ❌ .env NO existe"; ((errors++)); }
[ -f .env.example ] && echo "  ✅ .env.example existe" || { echo "  ❌ .env.example NO existe"; ((errors++)); }
[ -f compose.yml ] && echo "  ✅ compose.yml existe" || { echo "  ❌ compose.yml NO existe"; ((errors++)); }
[ -f Makefile ] && echo "  ✅ Makefile existe" || { echo "  ❌ Makefile NO existe"; ((errors++)); }
echo ""

# 2. .gitignore
echo "🔒 Verificando .gitignore..."
grep -q "^\.env$" .gitignore && echo "  ✅ .env en .gitignore" || { echo "  ❌ .env NO en .gitignore"; ((errors++)); }
echo ""

# 3. Frontend compilado
echo "🎨 Verificando frontend..."
[ -d frontend/dist ] && echo "  ✅ Frontend compilado" || { echo "  ⚠️  Frontend NO compilado (ejecutar: npm run build)"; }
echo ""

# 4. Docker Compose válido
echo "🐳 Verificando Docker Compose..."
docker compose config --quiet && echo "  ✅ compose.yml válido" || { echo "  ❌ compose.yml tiene errores"; ((errors++)); }
echo ""

# 5. Servicios corriendo
echo "🚀 Verificando servicios..."
if docker compose ps | grep -q "Up"; then
    echo "  ✅ Servicios corriendo"
    
    # Detalles de cada servicio
    docker compose ps | grep "Up" | awk '{print "    -", $1}'
else
    echo "  ⚠️  Servicios NO están corriendo (ejecutar: make up)"
fi
echo ""

# 6. Resultado final
echo "=========================================="
if [ $errors -eq 0 ]; then
    echo "✅ TODOS LOS CHECKS PASADOS - Listo para entregar!"
else
    echo "❌ Se encontraron $errors errores - Revisar antes de entregar"
fi
echo "=========================================="
```

Guarda este script como `check.sh` y ejecútalo:

```bash
chmod +x check.sh
./check.sh
```

---

## 📧 Lista de Entrega

Al entregar el proyecto, asegúrate de incluir:

1. ✅ Repositorio Git completo
2. ✅ `.env.example` (sin credenciales)
3. ✅ `compose.yml` completo
4. ✅ `Makefile` funcional
5. ✅ Documentación (README o INSTRUCCIONES)
6. ✅ Frontend compilado (o instrucciones de compilación)
7. ✅ Configuración de Nginx
8. ✅ Dockerfile del backend
9. ✅ CORS configurado para ngrok

**NO INCLUIR:**
- ❌ `.env` real (con credenciales)
- ❌ `node_modules/`
- ❌ `vendor/`
- ❌ `backend/var/` (cache de Symfony)
- ❌ Archivos de IDE (.idea/, .vscode/)

---

## 🎯 Comandos de Verificación Rápida

```bash
# Verificación completa en 1 minuto
make up && sleep 30 && \
echo "✅ Frontend: http://localhost" && \
echo "✅ Backend: http://localhost/api" && \
echo "✅ Portainer: http://localhost:9000" && \
echo "✅ ngrok: http://localhost:4040" && \
make ngrok-url
```

---

**¡Buena suerte con la entrega! 🚀**
