# 🔒 Archivos Sensibles - NO SUBIR A GIT

## ⚠️ NUNCA subas estos archivos al repositorio:

### 1. `.env` (Root y Backend)
**Contiene:**
- Contraseñas de base de datos
- Tokens de ngrok
- Secretos de aplicación (APP_SECRET)
- Passphrases JWT

**Por qué es peligroso:**
- Expone credenciales a usuarios no autorizados
- Compromete la seguridad de la aplicación
- Permite acceso a servicios externos (ngrok)

### 2. `/backend/config/jwt/*.pem`
**Contiene:**
- Claves privadas JWT (`private.pem`)
- Claves públicas JWT (`public.pem`)

**Por qué es peligroso:**
- Permite generar tokens JWT válidos
- Compromete la autenticación de usuarios
- Acceso completo al API como admin

### 3. `.docker/config.json`
**Contiene:**
- Configuración de Docker
- Potencialmente credenciales de registries

## ✅ En su lugar usa:

- **`.env.example`** - Plantilla sin valores reales
- **Generación automática** - El script `init.sh` genera las claves
- **Variables de entorno** - En producción usa secretos del servidor

## 🔍 Verificar antes de hacer commit:

```bash
# Ver qué archivos están staged
git status

# Si ves .env o archivos .pem, remuévelos:
git rm --cached .env
git rm --cached backend/config/jwt/*.pem
```

## 🛡️ Si ya subiste archivos sensibles:

1. **Genera nuevas credenciales** (las antiguas están comprometidas)
2. **Elimina el archivo del historial** usando git-filter-repo o BFG:
   ```bash
   git filter-repo --path .env --invert-paths
   git push --force
   ```
3. **Actualiza todos los servicios** con las nuevas credenciales
