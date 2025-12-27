#!/bin/bash
set -e

# Deploy usando docker-compose
docker compose -f docker-compose.prod.yml up -d

# Mantener el contenedor corriendo
tail -f /dev/null
