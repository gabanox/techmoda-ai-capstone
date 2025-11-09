# TechModa Serverless Capstone

[![Abrir en GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=master&repo=gabanox/techmoda-serverless-capstone-starter)

API de Catálogo de Productos de E-commerce de Moda construida con Tecnologías Serverless de AWS

---

## 🚀 NUEVO: Despliegue en 10 Minutos

**¿Primera vez aquí?** Las funciones Lambda ya están implementadas y listas para desplegar.

👉 **Lee el [QUICKSTART.md](QUICKSTART.md)** para desplegar en 10 minutos

---

## 🎯 Scripts Simplificados para Alumnos

Hemos creado scripts simplificados para hacer el despliegue y gestión más fácil:

### Desplegar Todo (Backend + Frontend)
```bash
./scripts/deploy-all.sh
```
Este script hace TODO automáticamente:
- ✅ Construye el backend (SAM)
- ✅ Despliega el backend a AWS
- ✅ Construye el frontend (React)
- ✅ Despliega el frontend a S3/CloudFront
- ✅ Te muestra las URLs al finalizar

### Ver Estado del Despliegue
```bash
./scripts/status.sh
```
Muestra:
- Estado actual del stack
- URLs de API y Frontend
- Número de productos en la base de datos
- Comandos útiles

### Eliminar Todos los Recursos
```bash
./scripts/delete-all.sh
```
Elimina TODO para evitar cargos:
- API Gateway
- Funciones Lambda
- Tabla DynamoDB
- Bucket S3 y CloudFront

**💡 Recomendación**: Usa estos scripts para una experiencia más simple y directa.

---

## Inicio Rápido con GitHub Codespaces

**Recomendado**: Usa GitHub Codespaces para un entorno de desarrollo preconfigurado con AWS CLI, SAM CLI y Node.js 18.x ya instalados.

1. Haz clic en el botón **"Abrir en GitHub Codespaces"** arriba
2. Espera a que el entorno se construya (2-3 minutos)
3. **Configura las credenciales de AWS** - Consulta [AWS_CREDENTIALS_SETUP.md](AWS_CREDENTIALS_SETUP.md) para instrucciones detalladas
4. Sigue la [Guía de Implementación](#guía-de-implementación) a continuación

### Configuración de Credenciales de AWS

Antes de desplegar, debes configurar las credenciales de AWS en GitHub:

1. Ve a la **Configuración** de tu repositorio → **Secrets and variables** → **Codespaces**
2. Agrega tres secretos:
   - `AWS_ACCESS_KEY_ID` - Tu clave de acceso de AWS
   - `AWS_SECRET_ACCESS_KEY` - Tu clave secreta de AWS
   - `AWS_DEFAULT_REGION` - Tu región de AWS (ej., `us-east-1`)
3. Reconstruye tu Codespace para cargar las credenciales

Para instrucciones detalladas paso a paso con capturas de pantalla, consulta **[AWS_CREDENTIALS_SETUP.md](AWS_CREDENTIALS_SETUP.md)**.

## Descripción General

TechModa es una API REST serverless para gestionar un catálogo de productos de e-commerce de moda. Este proyecto capstone demuestra dominio de patrones de arquitectura serverless de AWS utilizando Lambda, API Gateway y DynamoDB.

### Objetivos de Aprendizaje

Al completar este proyecto, podrás:

- Diseñar arquitecturas serverless usando Lambda, API Gateway y DynamoDB
- Implementar APIs RESTful con métodos HTTP apropiados y códigos de estado
- Desplegar infraestructura como código usando AWS SAM
- Probar APIs manualmente usando curl e interpretar respuestas
- Depurar aplicaciones serverless usando CloudWatch Logs y X-Ray
- Estimar y gestionar costos de AWS para aplicaciones serverless
- Usar herramientas de IA efectivamente (Claude Code) para acelerar el desarrollo
- Documentar proyectos técnicos para propósitos de portafolio
- Seguir las mejores prácticas de AWS para seguridad y observabilidad

## Arquitectura

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   Cliente   │─────▶│ API Gateway │─────▶│   Lambda    │─────▶│  DynamoDB   │
│  (curl/     │◀─────│   (REST)    │◀─────│ (Node.js)   │◀─────│   (NoSQL)   │
│  navegador) │      └─────────────┘      └─────────────┘      └─────────────┘
└─────────────┘              │                     │
                             │                     │
                             ▼                     ▼
                      ┌─────────────┐      ┌─────────────┐
                      │  CloudWatch │      │   X-Ray     │
                      │    Logs     │      │   Tracing   │
                      └─────────────┘      └─────────────┘
```

### Componentes

- **API Gateway**: API REST con 5 endpoints para operaciones CRUD
- **Lambda Functions**: 5 funciones Node.js 18.x (ListItems, CreateItem, GetItem, UpdateItem, DeleteItem)
- **DynamoDB**: Base de datos NoSQL con facturación PAY_PER_REQUEST
- **CloudWatch**: Registro centralizado para ejecución de Lambda
- **X-Ray**: Rastreo distribuido para observabilidad de rendimiento

Para documentación detallada de arquitectura, consulta [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## Prerequisitos

Antes de comenzar, asegúrate de tener:

- **Cuenta de AWS** con permisos apropiados
- **AWS CLI v2** instalado y configurado ([Guía de Instalación](docs/prompts/01_ENVIRONMENT_SETUP.md))
- **AWS SAM CLI** instalado ([Guía de Instalación](docs/prompts/01_ENVIRONMENT_SETUP.md))
- **Node.js 18.x** o posterior
- **Git** para control de versiones
- **Conocimiento básico** de JavaScript, APIs REST y servicios de AWS

## Guía de Implementación

**🚀 Opción Rápida**: Si quieres desplegar todo de una vez, usa `./scripts/deploy-all.sh` (ver [Scripts Simplificados](#-scripts-simplificados-para-alumnos) arriba)

**📚 Opción Paso a Paso**: Sigue esta guía para entender cada paso del proceso

### 1. Clonar el Repositorio

**Nota**: Si usas Codespaces, omite este paso - el repositorio ya está clonado.

```bash
git clone <repository-url>
cd techmoda-serverless-capstone-starter
```

### 2. Revisar la Estructura del Proyecto

```
techmoda-serverless-capstone-starter/
├── template.yaml              # Plantilla SAM (infraestructura como código)
├── functions/                 # Código fuente de funciones Lambda
│   ├── list-items/           # GET /products
│   ├── create-item/          # POST /products
│   ├── get-item/             # GET /products/{id}
│   ├── update-item/          # PUT /products/{id}
│   └── delete-item/          # DELETE /products/{id}
├── frontend/                  # Frontend React (opcional)
├── docs/                      # Documentación
│   ├── specs/                # Especificaciones detalladas de funciones
│   └── prompts/              # Plantillas de prompts para Claude Code
├── scripts/                   # Scripts auxiliares de despliegue
│   ├── build.sh              # Construir la aplicación SAM
│   ├── deploy.sh             # Desplegar a AWS
│   ├── delete.sh             # Limpiar recursos
│   ├── build-frontend.sh     # Construir el frontend
│   └── deploy-frontend.sh    # Desplegar frontend a S3
└── README.md                  # Este archivo
```

### 3. Implementar las Funciones Lambda

Cada función Lambda en el directorio `functions/` contiene código de marcador con comentarios TODO. Sigue estos pasos:

1. **Lee la especificación** de cada función en `docs/specs/`
2. **Usa las plantillas de prompts** en `docs/prompts/02_LAMBDA_IMPLEMENTATION.md` con Claude Code
3. **Implementa la lógica de negocio** siguiendo el enfoque de desarrollo guiado por especificaciones
4. **Prueba localmente** (opcional) o despliega y prueba en AWS

Consulta [CAPSTONE_OVERVIEW.md](CAPSTONE_OVERVIEW.md) para orientación detallada de implementación.

### 4. Construir la Aplicación

```bash
# Usando el script auxiliar
./scripts/build.sh

# O directamente con SAM CLI
sam build
```

Este comando:
- Instala las dependencias de Node.js para cada función
- Prepara el paquete de despliegue
- Crea el directorio `.aws-sam/build/`

### 5. Desplegar a AWS

#### Primer Despliegue (Guiado)

```bash
# Usando el script auxiliar
./scripts/deploy.sh

# O directamente con SAM CLI
sam deploy --guided
```

**IMPORTANTE**: Se te harán varias preguntas. Usa estos valores:

```
Stack Name [techmoda-capstone]: tu-nombre-con-guiones-medios
AWS Region [us-east-1]:
#Shows you resources changes to be deployed and require a 'Y' to initiate deploy
Confirm changes before deploy [Y/n]: y
#SAM needs permission to be able to create roles to connect to the resources in your template
Allow SAM CLI IAM role creation [Y/n]: y
#Preserves the state of previously provisioned resources when an operation fails
Disable rollback [y/N]: y
ListItemsFunction has no authentication. Is this okay? [y/N]: y
CreateItemFunction has no authentication. Is this okay? [y/N]: y
GetItemFunction has no authentication. Is this okay? [y/N]: y
UpdateItemFunction has no authentication. Is this okay? [y/N]: y
DeleteItemFunction has no authentication. Is this okay? [y/N]: y
Save arguments to configuration file [Y/n]: y
SAM configuration file [samconfig.toml]:
SAM configuration environment [default]:
```

**Notas**:
- **Stack Name**: Reemplaza `tu-nombre-con-guiones-medios` con tu nombre real usando guiones (ej., `juan-perez`, `maria-garcia`)
- **AWS Region**: Presiona Enter para usar el valor predeterminado `us-east-1` (o ingresa tu región preferida)
- **Advertencias de no autenticación**: Esto es esperado para este proyecto educativo (no estamos usando API keys o Cognito)

#### Despliegues Subsiguientes

```bash
# Usando el script auxiliar
./scripts/deploy.sh

# O directamente con SAM CLI
sam deploy
```

### 6. Probar tu API

Después del despliegue, recibirás una URL de API en las salidas:

```
Outputs:
  ApiUrl: https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/Prod
```

Copia esta URL y prueba tus endpoints usando curl. Consulta [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md) para instrucciones completas de prueba.

**Ejemplo de prueba rápida:**

```bash
# Configura tu URL de API
export API_URL="https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/Prod"

# Crea un producto
curl -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Classic Denim Jacket",
    "description": "Timeless blue denim jacket",
    "price": 79.99,
    "category": "Outerwear",
    "imageUrl": "https://example.com/jacket.jpg"
  }'

# Lista todos los productos
curl $API_URL/products
```

### 7. Construir y Desplegar el Frontend (Opcional)

El capstone incluye un frontend React para visualizar y gestionar productos.

#### Construir el Frontend

```bash
./scripts/build-frontend.sh
```

Esto:
- Instalará las dependencias del frontend
- Construirá el bundle de producción
- Generará archivos estáticos en `frontend/dist/`

#### Desplegar Frontend a S3

Después de desplegar el backend (paso 5), despliega el frontend:

```bash
./scripts/deploy-frontend.sh
```

Esto:
- Obtendrá la URL de API de las salidas de CloudFormation
- Reemplazará el marcador de URL de API en los archivos construidos
- Subirá el frontend a S3
- Mostrará la URL de CloudFront

**Accede a tu frontend**: Usa la URL de CloudFront de la salida.

**Nota**: El despliegue de la distribución de CloudFront puede tardar 15-20 minutos. Si obtienes un error "Not Found" inmediatamente después del despliegue, espera unos minutos e intenta de nuevo.

#### Desarrollo Local del Frontend

Para ejecutar el frontend localmente:

1. Crea un archivo `.env` en el directorio `frontend/`:
   ```bash
   cd frontend
   cp .env.example .env
   ```

2. Actualiza `.env` con tu URL de API:
   ```
   VITE_API_URL=https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/Prod
   ```

3. Instala las dependencias y ejecuta:
   ```bash
   npm install
   npm run dev
   ```

4. Abre tu navegador en la URL mostrada (típicamente http://localhost:5173)

Consulta [frontend/README.md](frontend/README.md) para más detalles.

### 8. Limpiar Recursos

**IMPORTANTE**: Para evitar cargos de AWS, elimina tu stack después de probar:

```bash
# Opción 1: Script simplificado (RECOMENDADO)
./scripts/delete-all.sh

# Opción 2: Script original
./scripts/delete.sh

# Opción 3: Directamente con SAM CLI
sam delete --stack-name techmoda-capstone
```

**Nota**: Esto eliminará la API, funciones Lambda, tabla DynamoDB, bucket S3 y distribución CloudFront.

Consulta [docs/COST_AND_CLEANUP.md](docs/COST_AND_CLEANUP.md) para estimaciones de costos y mejores prácticas de limpieza.

## Documentación

### Documentación Principal
- [CAPSTONE_OVERVIEW.md](CAPSTONE_OVERVIEW.md) - Descripción del proyecto y requisitos de entrega
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - Arquitectura detallada y descripciones de componentes
- [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md) - Instrucciones completas de prueba con ejemplos curl
- [docs/COST_AND_CLEANUP.md](docs/COST_AND_CLEANUP.md) - Estimación de costos y procedimientos de limpieza

### Especificaciones de Funciones Lambda
- [docs/specs/LIST_ITEMS_SPEC.md](docs/specs/LIST_ITEMS_SPEC.md) - Listar todos los productos
- [docs/specs/CREATE_ITEM_SPEC.md](docs/specs/CREATE_ITEM_SPEC.md) - Crear un nuevo producto
- [docs/specs/GET_ITEM_SPEC.md](docs/specs/GET_ITEM_SPEC.md) - Obtener un producto por ID
- [docs/specs/UPDATE_ITEM_SPEC.md](docs/specs/UPDATE_ITEM_SPEC.md) - Actualizar un producto existente
- [docs/specs/DELETE_ITEM_SPEC.md](docs/specs/DELETE_ITEM_SPEC.md) - Eliminar un producto

### Plantillas de Prompts (Para Claude Code)
- [docs/prompts/01_ENVIRONMENT_SETUP.md](docs/prompts/01_ENVIRONMENT_SETUP.md) - Instalación de AWS CLI y SAM
- [docs/prompts/02_LAMBDA_IMPLEMENTATION.md](docs/prompts/02_LAMBDA_IMPLEMENTATION.md) - Implementaciones de funciones Lambda
- [docs/prompts/03_DEPLOYMENT.md](docs/prompts/03_DEPLOYMENT.md) - Construcción y despliegue
- [docs/prompts/04_TESTING.md](docs/prompts/04_TESTING.md) - Pruebas de API con curl
- [docs/prompts/05_DEBUGGING.md](docs/prompts/05_DEBUGGING.md) - Solución de problemas comunes
- [docs/prompts/06_OPERATIONS.md](docs/prompts/06_OPERATIONS.md) - Gestión de costos y limpieza

## Solución de Problemas

### Problemas Comunes

**Fallos de Construcción**
- Asegúrate de que Node.js 18.x esté instalado: `node --version`
- Verifica que package.json exista en cada directorio de función
- Elimina la carpeta `.aws-sam` y reconstruye: `rm -rf .aws-sam && sam build`

**Fallos de Despliegue**
- Verifica las credenciales de AWS: `aws sts get-caller-identity`
- Verifica los permisos IAM para CloudFormation, Lambda, API Gateway, DynamoDB
- Revisa los eventos de CloudFormation en la Consola de AWS para errores específicos

**Errores de API (404, 500)**
- Verifica los CloudWatch Logs para errores de función Lambda
- Verifica que la variable de entorno `PRODUCTS_TABLE` esté configurada correctamente
- Asegúrate de que la tabla DynamoDB exista: `aws dynamodb list-tables`
- Revisa los rastros de X-Ray en la Consola de AWS

**Errores de Permisos**
- Verifica que las políticas IAM de la plantilla SAM coincidan con los requisitos de la función
- Verifica que el rol de ejecución de Lambda tenga permisos de DynamoDB
- Asegúrate de que CloudFormation tenga CAPABILITY_IAM

Para guía detallada de depuración, consulta [docs/prompts/05_DEBUGGING.md](docs/prompts/05_DEBUGGING.md)

## Endpoints de API

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | /products | Listar todos los productos |
| POST | /products | Crear un nuevo producto |
| GET | /products/{id} | Obtener un producto por ID |
| PUT | /products/{id} | Actualizar un producto existente |
| DELETE | /products/{id} | Eliminar un producto |

## Esquema de Datos

### Objeto Producto

```json
{
  "productId": "string (UUID)",
  "name": "string (requerido)",
  "description": "string",
  "price": "number (requerido)",
  "category": "string",
  "imageUrl": "string (URL)",
  "createdAt": "string (marca de tiempo ISO 8601)",
  "updatedAt": "string (marca de tiempo ISO 8601)"
}
```

## Requisitos de Entrega

Para este proyecto capstone, debes entregar:

1. **URL del Repositorio GitHub** con:
   - Plantilla SAM completa (template.yaml)
   - Las 5 funciones Lambda implementadas
   - README con diagrama de arquitectura e instrucciones de despliegue
   - Ejemplos de prueba curl funcionales

2. **Diagrama de Arquitectura** (en README o archivo separado)

3. **Evidencia de Implementación Funcional** (capturas de pantalla opcionales o salida de curl)

Consulta [CAPSTONE_OVERVIEW.md](CAPSTONE_OVERVIEW.md) para criterios completos de entrega y evaluación.

## Estimación de Costos

Costos esperados de AWS para este proyecto capstone: **Menos de $1 USD**

Esto asume:
- Desarrollo y pruebas durante 1-2 días
- Aproximadamente 50-100 solicitudes de API
- Todos los servicios dentro de los límites de AWS Free Tier

**IMPORTANTE**: Elimina tu stack inmediatamente después de probar para evitar cargos continuos.

Para desglose detallado de costos, consulta [docs/COST_AND_CLEANUP.md](docs/COST_AND_CLEANUP.md)

## Recursos

- [Documentación de AWS SAM](https://docs.aws.amazon.com/serverless-application-model/)
- [Guía del Desarrollador de AWS Lambda](https://docs.aws.amazon.com/lambda/)
- [Guía del Desarrollador de DynamoDB](https://docs.aws.amazon.com/dynamodb/)
- [Documentación de API Gateway REST API](https://docs.aws.amazon.com/apigateway/)

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - consulta el archivo [LICENSE](LICENSE) para más detalles.

## Soporte

Para preguntas o problemas:
1. Revisa la documentación en `docs/`
2. Consulta las plantillas de prompts en `docs/prompts/`
3. Consulta a tu instructor de bootcamp
4. Revisa los CloudWatch Logs para detalles de errores

---

**¡Buena suerte con tu proyecto capstone!** 🚀
