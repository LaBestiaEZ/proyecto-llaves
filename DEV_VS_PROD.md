# 🔄 Guía Rápida: Desarrollo vs Producción

## 📋 Diferencias entre Modos

### 🔧 Modo Desarrollo (`compose.dev.yml`)

**Servicios:**
- ✅ PostgreSQL (puerto 5432)
- ✅ Backend Symfony (modo dev con debug)
- ✅ Nginx Backend API (puerto 8080)
- ✅ Frontend Angular (puerto 4200 - hot reload)
- ❌ Sin Portainer
- ❌ Sin ngrok

**Características:**
- Frontend con **hot-reload** (cambios en vivo)
- Backend con **APP_DEBUG=1**
- Volúmenes: código montado para edición en vivo
- Puertos directos expuestos
- CORS solo para localhost

**Uso:**
```powershell
# Levantar
make dev-up

# Ver logs
make dev-logs

# Detener
make dev-down
```

**URLs:**
- Frontend: http://localhost:4200
- Backend API: http://localhost:8080/api
- Base de datos: localhost:5432

---

### 🚀 Modo Producción/Práctica (`compose.yml`)

**Servicios:**
- ✅ PostgreSQL (puerto 5432)
- ✅ Backend Symfony (modo prod)
- ✅ Nginx Proxy Inverso (puerto 80) - sirve frontend + API
- ✅ Portainer (puerto 9000)
- ✅ ngrok (puerto 4040)
- ❌ Frontend debe compilarse previamente

**Características:**
- Frontend **pre-compilado** (npm run build)
- Backend con **APP_DEBUG=0**
- Nginx como proxy inverso único
- Gestión visual con Portainer
- Expuesto a internet con ngrok
- CORS configurado para ngrok

**Uso:**
```powershell
# Compilar frontend primero
cd frontend && npm run build && cd ..

# Levantar
make up

# Ver logs
make logs

# Detener
make down
```

**URLs:**
- Aplicación completa: http://localhost
- Backend API: http://localhost/api
- Portainer: http://localhost:9000
- ngrok Dashboard: http://localhost:4040
- Público: https://[id].ngrok-free.app

---

## 🎯 ¿Cuándo usar cada uno?

### Usa DESARROLLO cuando:
- ✅ Estás programando/desarrollando
- ✅ Necesitas ver cambios sin recompilar
- ✅ Trabajas solo en local
- ✅ Quieres iteración rápida
- ✅ No necesitas probar ngrok o Portainer

### Usa PRODUCCIÓN cuando:
- ✅ Vas a presentar/entregar la práctica
- ✅ Necesitas exponer a internet (ngrok)
- ✅ Quieres gestión visual (Portainer)
- ✅ Pruebas de integración completas
- ✅ Simulación de entorno real

---

## 📊 Comparativa Rápida

| Característica | Desarrollo | Producción |
|---------------|------------|------------|
| **Comando** | `make dev-up` | `make up` |
| **Frontend** | Hot-reload (4200) | Pre-compilado (80) |
| **Backend API** | Puerto 8080 | Puerto 80/api |
| **Debug** | Activado | Desactivado |
| **Portainer** | ❌ | ✅ |
| **ngrok** | ❌ | ✅ |
| **Volúmenes** | Código montado | Solo persistencia |
| **CORS** | localhost | localhost + ngrok |
| **Velocidad** | Rápido | Requiere build |

---

## 🚀 Flujos de Trabajo

### Desarrollo Diario

```powershell
# 1. Primera vez del día
make dev-up

# 2. Trabajar en código
# - Edita archivos en /frontend/src o /backend/src
# - Los cambios se reflejan automáticamente

# 3. Ver logs si hay errores
make dev-logs-frontend  # o dev-logs-backend

# 4. Al terminar
make dev-down
```

### Preparar para Entrega/Demo

```powershell
# 1. Parar desarrollo
make dev-down

# 2. Compilar frontend
cd frontend
npm run build
cd ..

# 3. Configurar ngrok
notepad .env  # Añadir NGROK_AUTHTOKEN

# 4. Levantar producción
make up

# 5. Verificar
make ps
make ngrok-url

# 6. Abrir en navegador
start http://localhost
start http://localhost:4040
```

---

## 🔄 Migrar entre Modos

### De Desarrollo → Producción

```powershell
# Detener desarrollo
make dev-down

# Compilar frontend
cd frontend && npm run build && cd ..

# Levantar producción
make up
```

### De Producción → Desarrollo

```powershell
# Detener producción
make down

# Levantar desarrollo
make dev-up
```

---

## ⚠️ Notas Importantes

### Base de Datos

Los dos modos usan **volúmenes separados**:
- Desarrollo: `postgres_data_dev`
- Producción: `postgres_data`

Si necesitas compartir datos:

```powershell
# Exportar de desarrollo
make dev-up
make dev-shell-db
# Dentro: \copy ...

# Importar a producción
make up
make shell-db
# Dentro: \copy ...
```

### Variables de Entorno

Ambos modos usan el mismo archivo `.env`, pero:
- **Desarrollo:** Usa valores por defecto si no existen
- **Producción:** Requiere NGROK_AUTHTOKEN configurado

### Puertos

No puedes ejecutar ambos modos simultáneamente (conflicto en puerto 5432 de PostgreSQL).

---

## 🎓 Comandos Útiles

### Desarrollo

```powershell
make dev-up          # Iniciar
make dev-down        # Detener
make dev-restart     # Reiniciar
make dev-logs        # Ver logs
make dev-ps          # Ver estado
make dev-install     # Instalar dependencias
make dev-migrate     # Ejecutar migraciones
make dev-clean       # Limpiar todo
```

### Producción

```powershell
make up              # Iniciar
make down            # Detener
make restart         # Reiniciar
make logs            # Ver logs
make ps              # Ver estado
make install         # Instalar dependencias
make migrate         # Ejecutar migraciones
make ngrok-url       # Ver URL pública
make clean           # Limpiar todo
```

### Ayuda

```powershell
make help            # Ver todos los comandos disponibles
```

---

## 😊 Recomendación

Para día a día mientras desarrollas:
```powershell
make dev-up
```

Para presentar la práctica:
```powershell
cd frontend && npm run build && cd .. && make up
```

¡Así de simple! 🎉
