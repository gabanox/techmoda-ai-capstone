# Scripts de Despliegue - TechModa

Este directorio contiene scripts para facilitar el despliegue y gestión de la aplicación TechModa.

## 📋 Índice de Scripts

### 🚀 Scripts Simplificados (Recomendados para Alumnos)

| Script | Descripción | Uso |
|--------|-------------|-----|
| `deploy-all.sh` | **Despliega TODO** (backend + frontend) en un solo comando | `./scripts/deploy-all.sh` |
| `delete-all.sh` | **Elimina TODO** para evitar cargos de AWS | `./scripts/delete-all.sh` |
| `status.sh` | **Muestra el estado** actual del despliegue con URLs | `./scripts/status.sh` |

### 🔧 Scripts Individuales (Para Control Detallado)

| Script | Descripción | Uso |
|--------|-------------|-----|
| `build.sh` | Construye solo el backend (SAM) | `./scripts/build.sh` |
| `deploy.sh` | Despliega solo el backend | `./scripts/deploy.sh` |
| `build-frontend.sh` | Construye solo el frontend (React) | `./scripts/build-frontend.sh` |
| `deploy-frontend.sh` | Despliega solo el frontend a S3 | `./scripts/deploy-frontend.sh` |
| `delete.sh` | Elimina el stack (equivalente a delete-all.sh) | `./scripts/delete.sh` |

---

## 🎯 Guía de Uso

### Primer Despliegue

```bash
# Opción Simple (TODO EN UNO)
./scripts/deploy-all.sh

# Opción Paso a Paso
./scripts/build.sh           # 1. Construir backend
./scripts/deploy.sh          # 2. Desplegar backend
./scripts/build-frontend.sh  # 3. Construir frontend
./scripts/deploy-frontend.sh # 4. Desplegar frontend
```

### Verificar Estado

```bash
./scripts/status.sh
```

Esto muestra:
- ✅ Estado del stack de CloudFormation
- 🔗 URL de la API Backend
- 🌐 URL del Frontend (CloudFront)
- 🗄️ Nombre de la tabla DynamoDB y cantidad de productos
- 📝 Comandos útiles

### Eliminar Todo

```bash
./scripts/delete-all.sh
```

**⚠️ IMPORTANTE**: Este comando elimina TODOS los recursos de AWS:
- API Gateway
- 5 Funciones Lambda
- Tabla DynamoDB (con todos los datos)
- Bucket S3
- Distribución CloudFront
- Roles y políticas IAM

---

## 📖 Detalles de Scripts Simplificados

### `deploy-all.sh`

**¿Qué hace?**
1. Construye el backend con SAM (`sam build`)
2. Despliega el backend a AWS (`sam deploy`)
3. Instala dependencias del frontend (`npm install`)
4. Construye el frontend (`npm run build`)
5. Despliega el frontend a S3/CloudFront
6. Muestra las URLs finales

**Ventajas:**
- ✅ Un solo comando para desplegar todo
- ✅ No necesitas recordar múltiples pasos
- ✅ Manejo automático de errores
- ✅ Feedback visual del progreso

**Uso:**
```bash
./scripts/deploy-all.sh
```

**Tiempo estimado:** 3-5 minutos

---

### `delete-all.sh`

**¿Qué hace?**
1. Verifica que el stack existe
2. Muestra una lista de recursos que serán eliminados
3. Pide confirmación explícita (debes escribir "si")
4. Elimina el stack completo con `sam delete`

**Ventajas:**
- ✅ Confirmación de seguridad
- ✅ Lista clara de lo que se eliminará
- ✅ Mensajes informativos
- ✅ Evita cargos no deseados

**Uso:**
```bash
./scripts/delete-all.sh
```

Cuando pregunte, escribe: `si` (o `SI` o `yes`)

**Tiempo estimado:** 2-3 minutos

---

### `status.sh`

**¿Qué hace?**
1. Busca el stack de CloudFormation
2. Obtiene el estado actual
3. Muestra todas las URLs y recursos
4. Cuenta los productos en DynamoDB
5. Sugiere comandos útiles

**Ventajas:**
- ✅ No necesitas entrar a la consola de AWS
- ✅ Toda la información en un solo lugar
- ✅ Útil para copiar URLs
- ✅ Verifica que todo esté funcionando

**Uso:**
```bash
./scripts/status.sh
```

**Salida ejemplo:**
```
==========================================
  TechModa - Estado del Despliegue
==========================================

🔍 Buscando stack: techmoda-capstone

📊 Estado del Stack
-------------------------------------------
Nombre: techmoda-capstone
Estado: CREATE_COMPLETE

📋 Información del Despliegue
-------------------------------------------
🔗 API Backend:
   https://abc123.execute-api.us-east-1.amazonaws.com/Prod

   Endpoints disponibles:
   • GET    https://abc123.execute-api.us-east-1.amazonaws.com/Prod/products
   • POST   https://abc123.execute-api.us-east-1.amazonaws.com/Prod/products
   • GET    https://abc123.execute-api.us-east-1.amazonaws.com/Prod/products/{id}
   • PUT    https://abc123.execute-api.us-east-1.amazonaws.com/Prod/products/{id}
   • DELETE https://abc123.execute-api.us-east-1.amazonaws.com/Prod/products/{id}

🌐 Frontend Web:
   https://d123abc.cloudfront.net

🗄️  Base de Datos:
   Tabla: techmoda-capstone-ProductsTable-ABC123
   Productos: 5

==========================================
```

---

## 🔧 Scripts Individuales (Avanzado)

Si necesitas más control sobre el proceso, puedes usar los scripts individuales:

### Backend

```bash
# Construir backend
./scripts/build.sh

# Desplegar backend
./scripts/deploy.sh
```

### Frontend

```bash
# Construir frontend
./scripts/build-frontend.sh

# Desplegar frontend
./scripts/deploy-frontend.sh
```

**Nota**: `deploy-frontend.sh` automáticamente obtiene la URL de API del backend desplegado y la inyecta en el frontend.

---

## ❓ Preguntas Frecuentes

### ¿Cuánto cuesta ejecutar estos scripts?

**Respuesta**: Menos de $1 USD si lo usas por 1-2 días y luego eliminas los recursos con `delete-all.sh`. Todos los servicios están dentro del Free Tier de AWS.

### ¿Puedo desplegar múltiples veces?

**Sí**. Puedes ejecutar `deploy-all.sh` múltiples veces. El segundo despliegue actualizará los recursos existentes.

### ¿Qué pasa si falla el despliegue?

1. Lee el mensaje de error
2. Verifica tus credenciales de AWS: `aws sts get-caller-identity`
3. Revisa los logs en CloudWatch
4. Consulta [docs/prompts/05_DEBUGGING.md](../docs/prompts/05_DEBUGGING.md)

### ¿Cómo cambio el nombre del stack?

Edita el archivo `samconfig.toml` y cambia el valor de `stack_name`.

### ¿Puedo usar estos scripts en mi máquina local?

**Sí**, siempre que tengas instalado:
- AWS CLI v2
- SAM CLI
- Node.js 18.x+
- Credenciales de AWS configuradas

### ¿CloudFront tarda mucho?

Sí, la primera vez puede tardar 15-20 minutos. Mientras tanto, puedes probar tu API directamente con curl.

---

## 💡 Mejores Prácticas

1. **Siempre ejecuta `status.sh`** después de desplegar para verificar las URLs
2. **Guarda las URLs** en algún lugar para hacer pruebas
3. **Ejecuta `delete-all.sh`** cuando termines de trabajar para evitar cargos
4. **Lee los mensajes** de error cuidadosamente - suelen indicar el problema exacto
5. **Verifica tus credenciales de AWS** antes de desplegar

---

## 📚 Recursos Adicionales

- [README principal](../README.md)
- [Guía de pruebas con curl](../docs/TESTING_GUIDE.md)
- [Guía de costos y limpieza](../docs/COST_AND_CLEANUP.md)
- [Documentación de SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-command-reference.html)

---

**¿Problemas?** Consulta tu instructor o revisa los CloudWatch Logs para más detalles.
