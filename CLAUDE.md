# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es este repo

Material educativo (Bootcamp Institute / AWS re/Start, pista **AI Practitioner AIF-C01**): un capstone
de e-commerce serverless ("TechModa") al que se le agregan capacidades de IA de AWS **una sesión de
~1 h a la vez**. Cada sesión (`sessions/S00..S11`) es autocontenida: guía + Lambda + snippet de SAM.

La documentación está en **español** (guías, comentarios, mensajes de scripts). Mantené ese idioma al
editar guías o agregar sesiones; el código y los identificadores están en inglés.

## Comandos

```bash
# Validar templates antes de comitear
sam validate --lint -t template.yaml
sam validate --lint -t template.full.yaml

# Observabilidad / estado
bash scripts/status.sh                       # estado del stack + Function URLs + conteo DDB
bash scripts/logs.sh [list|create|get|update|delete] [--tail|--errors|--since 1h|--filter TXT]

# Frontend (en frontend/)
npm run dev | build | lint | typecheck
npm test                                     # vitest (watch)
npx vitest run                               # una pasada
npx vitest run src/lib/api.test.ts           # un solo archivo
npx vitest run -t "nombre del test"          # un solo test
```

Para desarrollo local del frontend contra un backend ya desplegado: `cp frontend/.env.example
frontend/.env` y pegá la salida `ApiUrl` del stack en `VITE_API_URL`.

No hay tests de Python; las Lambdas de IA se validan con el `curl` de cada `GUIA.md`.

## Arquitectura

**Base (S0):** DynamoDB `${StackName}-Products` + **una** Lambda router Node.js + frontend React/Vite
en S3/CloudFront. Las 8 features de IA (S1–S8) son Lambdas Python 3.12 + boto3, cada una con su
propia Function URL, que llaman a un servicio de IA administrado y escriben el resultado de vuelta en
DynamoDB.

Dos decisiones dominan todo el diseño; **leé [`docs/SANDBOX-COMPAT.md`](docs/SANDBOX-COMPAT.md) antes
de agregar cualquier función:**

1. **Sin API Gateway ni `iam:CreateRole`.** El `LabRole` del sandbox Vocareum no los permite y un
   `CREATE_FAILED` revierte el stack entero. Por eso: **Lambda Function URLs** (`AuthType: NONE`,
   CORS `*`) y `Role: !Ref LabRoleArn` en **cada** función — nunca `Policies:` (mutuamente excluyentes
   en SAM), y nunca `Role` en `Globals.Function` (SAM no lo soporta ahí).
2. **El sandbox es efímero** (se recicla cada ~4 h). Ninguna sesión asume el estado de la anterior;
   `scripts/bootstrap.sh` reconstruye todo en 2–3 min. Ver `SESSION-PLAN.md`.

**El router (`functions/router/index.js`)** existe porque no hay API Gateway: se empaqueta con
`CodeUri: functions/` + `Handler: router/index.handler`, así puede `require('../list-items')` y reusar
los 5 handlers CRUD sin duplicar lógica. Parsea el payload v2.0 de Function URL
(`requestContext.http.method`, `rawPath`, body base64) y reconstruye `pathParameters.id`. Con una sola
base URL el frontend (`frontend/src/lib/api.ts`) no cambia.

**Tres templates, elegí según el caso:**

| Template | Contenido | Cuándo |
|---|---|---|
| `template.yaml` | solo S0 (+ CloudFront) | ruta progresiva: pegar el `template-snippet.yaml` de cada sesión |
| `template.sandbox.yaml` | Pista A sin CloudFront | lo que usa `bootstrap.sh` (levanta rápido) |
| `template.full.yaml` | base + S1–S8 + gobernanza | demo o revisar el resultado final |

## Despliegue

Todo corre **dentro del VS Code IDE del sandbox**, región **us-east-1**, stack **`techmoda-ai`**.
Verificá primero que estás autenticado: `aws sts get-caller-identity` debe responder (como `LabRole`).

### Primer despliegue

```bash
cp samconfig.us-east-1.example samconfig.toml   # una vez; samconfig.toml está en .gitignore
bash scripts/deploy-all.sh                      # backend + npm install + build + frontend a S3
```

`deploy-all.sh` orquesta los tres pasos; los individuales son `scripts/deploy.sh` (backend),
`scripts/build-frontend.sh` y `scripts/deploy-frontend.sh`. Toma ~3–5 min, más 15–20 min la primera vez
que CloudFront propaga (mientras tanto la API ya responde por `curl`).

### Backend

`scripts/deploy.sh` hace `sam build && sam deploy`. Si existe `samconfig.toml` usa esa config; si no,
pasa las flags explícitas. Las capabilities **no son opcionales**:

```bash
sam deploy --stack-name techmoda-ai --region us-east-1 \
  --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
  --resolve-s3 --no-confirm-changeset
```

`CAPABILITY_AUTO_EXPAND` es obligatoria (Transform SAM). `CAPABILITY_IAM` se mantiene por
compatibilidad del changeset aunque no se creen roles (las funciones reusan el `LabRole`).

Para desplegar en otra cuenta, sobreescribí el parámetro del rol:
`--parameter-overrides LabRoleArn=arn:aws:iam::<acct>:role/LabRole`.

Elegí el template según el caso (ver la tabla en Arquitectura). Con `template.full.yaml` o
`template.sandbox.yaml` hay que pasar `-t` **tanto a `build` como a `deploy`**:

```bash
sam build -t template.full.yaml
sam deploy -t template.full.yaml --stack-name techmoda-ai --region us-east-1 \
  --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND --resolve-s3 --no-confirm-changeset
```

### Frontend

`scripts/deploy-frontend.sh` lee los outputs del stack (`FrontendBucketName`, `ApiUrl`), inyecta la URL
en el build vía `scripts/inject-env.sh` (genera `env-config.js` — configuración en **runtime**, no
horneada en el bundle) y hace `aws s3 sync --delete`. Requiere que el backend ya esté desplegado y que
`frontend/dist/` exista (`npm run build`).

### Paso 0 de cada día (sandbox reciclado)

```bash
bash scripts/bootstrap.sh
```

Idempotente y seguro de correr siempre: `sam build && sam deploy` de `template.sandbox.yaml`, re-siembra
los 4 productos (`ai/seed/seed-products.sh`) e imprime las Function URLs. Si el sandbox no se recicló,
`sam deploy` no detecta cambios y termina en segundos.

### Verificar

```bash
bash scripts/status.sh
API=$(aws cloudformation describe-stacks --stack-name techmoda-ai --region us-east-1 \
       --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" --output text)
curl -s "${API%/}/products" | python3 -m json.tool    # debe listar los 4 productos
```

`ApiUrl` termina en `/` y **no** lleva `/Prod` (es una Function URL, no API Gateway) — de ahí el
`${API%/}` en todos los ejemplos.

### Cleanup

```bash
bash scripts/delete-all.sh          # pide confirmación explícita ("si"); borra el stack completo
bash scripts/fix-failed-delete.sh   # si quedó en DELETE_FAILED por buckets S3 no vacíos
```

Regla FinOps del capstone: ningún recurso de IA queda encendido entre sesiones más de lo necesario.
Cada `GUIA.md` trae su cleanup específico; detalles en `docs/COST_AND_CLEANUP.md`.

## Dos pistas (importante)

Verificado empíricamente en el sandbox (`docs/SANDBOX-COMPAT.md` tiene la matriz):

- **Pista A — corre en el sandbox:** S00, S01/S02 (Rekognition), S03 (Comprehend), S05 (Polly), S10.
- **Pista B — NO corre en el sandbox:** S04 (Translate), S06–S09 (Bedrock). El `LabRole` deniega
  `translate:TranslateText` y `bedrock:InvokeModel` con `AccessDeniedException`, y el rol no es
  modificable. Se demuestran en la cuenta Bootcamp. **No "arregles" esto agregando políticas IAM** —
  es una limitación de la cuenta, documentada a propósito.

## Al agregar una sesión o función

Checklist en `docs/SANDBOX-COMPAT.md` ("antes de mergear"). En resumen:

- `Role: !Ref LabRoleArn`, sin `Policies:`.
- HTTP → `FunctionUrlConfig`; nunca `Events: Type: Api` ni `AWS::Serverless::Api`.
- El handler saca sus parámetros de `rawPath` / `queryStringParameters` / body (no de
  `pathParameters`, que no existe en Function URLs).
- Output de la URL: `!GetAtt <LogicalId>FunctionUrl.FunctionUrl` (SAM crea el recurso `<LogicalId>Url`).
- Cada `GUIA.md` cierra con estimación de costo (marcada *verificar contra precios oficiales*) y
  bloque de cleanup.

## Gotchas conocidos

- **DynamoDB no acepta `float`** vía el resource de boto3: convertí a `Decimal(str(v))` antes del
  `update_item`, o el handler crashea con `TypeError: Float types are not supported`. Pasó con los
  `Confidence` de Rekognition en S01.
- Las Lambdas CRUD usan `nodejs22.x` (`nodejs18.x` está deprecada); las de IA, `python3.12`.
- Los IDs de modelo Bedrock viven en variables de entorno (`BEDROCK_MODEL_ID`, `EMBED_MODEL_ID`) y S06
  usa la **Converse API**, que es agnóstica al proveedor → cambiar de modelo no requiere tocar código.
  El default pineado (`anthropic.claude-3-haiku-20240307-v1:0`) es un ID de la integración legacy de
  Bedrock y corresponde a Claude 3 Haiku, cuyo retiro estaba anunciado para 2026-04-19: si una demo
  falla con 404 o "model not found", actualizá el ID antes de debuggear otra cosa. Con perfiles de
  inferencia cross-region el ID lleva prefijo `us.` (ver el comentario en
  `sessions/S06-bedrock-descripciones/functions/generate-description/app.py:26`).
- `docs/ARCHITECTURE.md:753-759` ("Privilegio Mínimo IAM") quedó del capstone base y contradice la
  realidad del LabRole descrita en las líneas 211-229 del mismo archivo.
- `README.md` menciona `ai/shared/` (helpers reutilizables); ese directorio no existe — solo `ai/seed/`.
