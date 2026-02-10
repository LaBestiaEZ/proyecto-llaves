# 📂 Guía de Archivos Docker Compose

## 🎯 ¿Qué archivo usar?

El proyecto tiene **3 archivos** de Docker Compose, cada uno para un propósito específico:

---

## 📋 Archivos Disponibles

### 1. `compose.yml` ⭐ (Despliegue Local Completo)

**Incluye:**
- ✅ PostgreSQL
- ✅ Backend Symfony
- ✅ Nginx (webserver)
- ✅ **Portainer**
- ✅ ngrok

**Usar cuando:**
- Despliegues desde tu máquina local con `make up`
- Quieres tener Portainer para gestión visual
- Primera vez configurando el proyecto
- Presentación de la práctica desde tu laptop

**Comando:**
```powershell
make up
# O:
docker compose -f compose.yml up -d
```

**Puertos:**
- Frontend/Backend: http://localhost
- Portainer: http://localhost:9000
- ngrok: http://localhost:4040

---

### 2. `compose.portainer.yml` 🐳 (Para Portainer Stack)

**Incluye:**
- ✅ PostgreSQL
- ✅ Backend Symfony
- ✅ Nginx (webserver)
- ❌ **SIN Portainer** (evita recursión)
- ✅ ngrok

**Usar cuando:**
- Despliegas desde **Portainer Stack** con Git
- Ya tienes Portainer instalado
- Despliegue en servidor remoto

**¿Por qué sin Portainer?**
Si despliegas desde Portainer Stack un compose que incluye Portainer, intentarías crear **Portainer dentro de Portainer** → Conflicto de puertos y error.

**Configuración en Portainer:**
```
Repository: https://github.com/LaBestiaEZ/proyecto-llaves
Branch: refs/heads/practica-despliegue
Compose path: compose.portainer.yml  ← IMPORTANTE
```

**Puertos:**
- Frontend/Backend: http://localhost (o IP del servidor)
- Portainer: Ya instalado (no se duplica)
- ngrok: http://localhost:4040

---

### 3. `compose.dev.yml` 🔧 (Desarrollo Local)

**Incluye:**
- ✅ PostgreSQL
- ✅ Backend Symfony (modo dev, debug ON)
- ✅ Nginx solo para API (puerto 8080)
- ✅ **Frontend con hot-reload** (puerto 4200)
- ❌ SIN Portainer
- ❌ SIN ngrok

**Usar cuando:**
- Estás desarrollando/programando
- Necesitas cambios en vivo sin recompilar
- Iteración rápida de código
- No necesitas exponer a internet

**Comando:**
```powershell
make dev-up
# O:
docker compose -f compose.dev.yml up -d
```

**Puertos:**
- Frontend (dev): http://localhost:4200
- Backend API: http://localhost:8080/api
- PostgreSQL: localhost:5432

---

## 🎯 Comparativa Rápida

| Característica | compose.yml | compose.portainer.yml | compose.dev.yml |
|----------------|-------------|----------------------|-----------------|
| **PostgreSQL** | ✅ | ✅ | ✅ |
| **Backend** | Prod | Prod | Dev (debug) |
| **Nginx** | Proxy completo | Proxy completo | Solo API |
| **Frontend** | Pre-compilado | Pre-compilado | Hot-reload |
| **Portainer** | ✅ Incluido | ❌ Usar externo | ❌ |
| **ngrok** | ✅ | ✅ | ❌ |
| **Puerto Web** | 80 | 80 | 4200 + 8080 |
| **Uso** | Local completo | Portainer Stack | Desarrollo |

---

## 🚀 Flujos de Trabajo

### Desarrollo Diario

```powershell
# Usar compose.dev.yml
make dev-up

# Código montado, cambios en vivo
# Frontend: http://localhost:4200
# Backend: http://localhost:8080/api

make dev-down
```

---

### Presentación Local (desde tu PC)

```powershell
# 1. Compilar frontend
cd frontend && npm run build && cd ..

# 2. Usar compose.yml (con Portainer)
make up

# Todo en uno:
# - Frontend/Backend: http://localhost
# - Portainer: http://localhost:9000
# - ngrok: http://localhost:4040

make down
```

---

### Despliegue con Portainer Stack (servidor/remoto)

**Paso 1: Instalar Portainer (solo primera vez)**

```bash
docker run -d \
  -p 9000:9000 -p 9443:9443 \
  --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

**Paso 2: Crear Stack en Portainer**

1. Ir a Stacks → Add Stack
2. Configurar:
   - Name: `proyecto-llaves`
   - Repository: `https://github.com/LaBestiaEZ/proyecto-llaves`
   - Branch: `refs/heads/practica-despliegue`
   - **Compose path:** `compose.portainer.yml` ⬅️ **CLAVE**
3. Añadir variables de entorno
4. Deploy

**Resultado:**
- Frontend/Backend: http://servidor
- Portainer: http://servidor:9000 (ya estaba)
- ngrok: URL pública

---

## ⚠️ Errores Comunes

### Error: "port 9000 is already allocated"

**Causa:** Intentas usar `compose.yml` desde Portainer Stack (incluye Portainer)

**Solución:** Usar `compose.portainer.yml` en su lugar

---

### Error: "frontend/dist not found"

**Causa:** Frontend no compilado (en compose.yml o compose.portainer.yml)

**Solución:**
```powershell
cd frontend
npm install
npm run build
cd ..

# Subir a Git
git add frontend/dist
git commit -m "Add: Frontend compilado"
git push
```

---

### Error: Cambios no se reflejan

**Causa:** Estás en modo producción (compose.yml)

**Solución:** Usar `compose.dev.yml` para desarrollo con hot-reload

---

## 📝 Resumen de Comandos

```powershell
# DESARROLLO (con hot-reload)
make dev-up
make dev-down

# PRODUCCIÓN LOCAL (con Portainer incluido)
make up
make down

# PRODUCCIÓN DESDE PORTAINER STACK
# → Usar compose.portainer.yml en la interfaz de Portainer

# VER AYUDA
make help
```

---

## 🎓 Recomendación Final

**Para la práctica evaluativa:**

1. **Desarrollo:** Usa `compose.dev.yml` mientras programas
2. **Demo en tu PC:** Usa `compose.yml` (incluye Portainer)
3. **Portainer Stack:** Usa `compose.portainer.yml` (sin Portainer)

**Esto evita:**
- ❌ Conflictos de puertos
- ❌ Portainer dentro de Portainer
- ❌ Confusión entre entornos
- ❌ Servicios redundantes

¡Mantén cada archivo para su propósito específico! 🎯
