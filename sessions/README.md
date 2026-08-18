# TechModa AI Capstone — Mapa de sesiones (AIF-C01)

Capstone de **AWS Certified AI Practitioner (AIF-C01)** construido sobre un catálogo
serverless de moda. Cada sesión es atómica (~1 h) y suma una capacidad de IA.

## Las 12 sesiones corren

Cada Lambda declara sus propias `Policies:` y **SAM le crea un rol de mínimo privilegio**
(ver [`docs/IAM.md`](../docs/IAM.md)). No hay rol preexistente ni account ID hardcodeado,
así que el capstone se despliega **en cualquier cuenta AWS donde puedas crear roles IAM**
(`iam:CreateRole`) y las 12 sesiones son ejecutables por el estudiante.

Lo único que sigue siendo un **requisito externo** es habilitar **Bedrock → Model access**
en la consola, en la región del deploy (es un setting **por región**), para S06–S09. Si esas
sesiones devuelven `AccessDeniedException`, ese es el primer sospechoso — no las políticas IAM.

> ℹ️ Versiones anteriores partían el capstone en dos pistas porque el `LabRole` del sandbox
> AWS re/Start denegaba `bedrock:InvokeModel` y `translate:TranslateText`. Con roles propios
> esa división desapareció; el contexto histórico está en
> [`docs/SANDBOX-COMPAT.md`](../docs/SANDBOX-COMPAT.md) §3.

## Tabla de sesiones

| Sesión | Capacidad | Servicio AWS | Dominio AIF-C01 | Requiere |
|---|---|---|---|---|
| **S00** Base | Catálogo CRUD serverless | Lambda + DynamoDB + S3/CloudFront | Base (lienzo) | — |
| **S01** Etiquetado | Auto-labels de imágenes | Rekognition `DetectLabels` | D1 | imagen real en S3 |
| **S02** Moderación | Moderación + alt-text accesible | Rekognition `DetectModerationLabels` | D1 · D4 | imagen real en S3 |
| **S03** Sentimiento | Análisis de reseñas | Comprehend | D1 | — |
| **S04** Multilingüe | Catálogo traducido | Translate | D1 | — |
| **S05** Voz | Fichas habladas | Polly | D1 | — |
| **S06** Descripciones | Texto generado por IA | Bedrock (Converse) | D2 · D3 | **Model access** |
| **S07** Búsqueda RAG | Embeddings + búsqueda semántica | Bedrock (Titan Embeddings) | D3 | **Model access** |
| **S08** Chatbot | Asistente de compras (RAG) | Bedrock | D2 · D3 | **Model access** |
| **S09** Guardrails | Filtros de contenido / sesgo | Bedrock Guardrails | D4 | **Model access** |
| **S10** Gobernanza | Logging de invocaciones + tags de costo | CloudWatch Logs / IAM | D5 | — |
| **S11** Integración | Demo end-to-end + cleanup | — | Cierre | — |

## Cómo correr todo de una

```bash
# 1. Desplegar base + las 8 features de IA + gobernanza
sam build -t template.full.yaml
sam deploy -t template.full.yaml --stack-name techmoda-ai --region us-east-1 \
  --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND --resolve-s3 --no-confirm-changeset
# 2. Sembrar productos
bash ai/seed/seed-products.sh
# 3. Verificar todo (CRUD E2E + las 9 Function URLs de IA, con PASS/FAIL por feature)
bash scripts/validate-all.sh
# 4. Demo narrada de punta a punta
bash sessions/S11-integracion-demo-cleanup/demo.sh
```

`CAPABILITY_IAM` **no es opcional**: el stack crea un rol por función.

Para S01/S02 (visión) hay que subir una imagen real al bucket de frontend y apuntar el `imageUrl`
del producto a esa ruta (`s3://...`). El nombre del bucket lleva tu account ID y región (el namespace
de S3 es global), así que sacalo del output `FrontendBucketName` del stack en vez de escribirlo:

```bash
BUCKET=$(aws cloudformation describe-stacks --stack-name techmoda-ai --region us-east-1 \
          --query "Stacks[0].Outputs[?OutputKey=='FrontendBucketName'].OutputValue" --output text)
aws s3 cp ./vestido.jpg "s3://$BUCKET/product-images/vestido.jpg"
```

La ruta progresiva (una sesión por vez, pegando cada `template-snippet.yaml` en
`template.yaml`) está en la `GUIA.md` de cada sesión. Ver también
[`../SESSION-PLAN.md`](../SESSION-PLAN.md).

## Permisos por sesión

La tabla completa (qué política lleva cada Lambda y por qué) está en
[`docs/IAM.md`](../docs/IAM.md#permisos-por-sesión). Resumen del criterio:

- **DynamoDB y S3** admiten ARN → se acotan **por recurso** (`DynamoDBCrudPolicy` /
  `DynamoDBReadPolicy` por tabla, `S3CrudPolicy` por bucket).
- **Bedrock** admite ARN → se acota **por ARN de modelo** (más `inference-profile/*` para los
  IDs con prefijo `us.`).
- **Rekognition, Comprehend, Translate y Polly** no admiten ARN en sus APIs `Detect*`/`Synthesize*`
  → se acotan **por acción**. `Resource: "*"` ahí no es descuido: es el límite real que existe.

## Estado verificado

**Desplegado y probado end-to-end el 2026-08-18** (cuenta `281248178297`, `us-east-1`,
`template.full.yaml`), ya **con los roles de mínimo privilegio que crea SAM** — un rol por función:

| Sesión | Llamada | Resultado |
|---|---|---|
| S00 | CRUD completo por la Function URL del router | ✅ incluido `stock` persistido |
| S01 | Rekognition `DetectLabels` (imagen `s3://`) | ✅ `Dress`, `Evening Dress`, `High Heel`… |
| S02 | Rekognition `DetectModerationLabels` + alt-text | ✅ `moderationStatus: APPROVED` |
| S03 | Comprehend `DetectDominantLanguage` + `DetectSentiment` | ✅ `es` / `POSITIVE` |
| S04 | `translate:TranslateText` (source `auto`) | ✅ traducción ES→EN |
| S05 | Polly `SynthesizeSpeech` + URL prefirmada | ✅ |
| S06 | Bedrock Converse (Claude Haiku 4.5) | ✅ descripción generada en español |
| S07 | Bedrock `titan-embed-text-v2:0` + búsqueda semántica | ✅ embedding de 1024 dims |
| S08 | Chatbot RAG | ✅ |

Reproducilo con un comando: `bash scripts/validate-all.sh` → **49 OK / 0 fallos**.

Tres bugs que **sólo aparecieron al desplegar de verdad** (y que ya están arreglados):

1. **Nombres de bucket S3.** `${StackName}-frontend` es de namespace **global** → `409
   BucketAlreadyExists` y el stack entero revierte. Ahora llevan `AccountId` y `Region`.
2. **Permisos downstream.** S03 necesita `comprehend:DetectDominantLanguage` además de
   `DetectSentiment`; y S04, con `SourceLanguageCode="auto"`, hace que **Translate llame a Comprehend
   por dentro con tu rol** → `DownstreamDependencyAccessDeniedException`. Ver
   [`docs/IAM.md`](../docs/IAM.md#el-permiso-que-no-se-ve-leyendo-el-código-dependencias-downstream).
3. **El model ID de Bedrock necesita el prefijo `us.`**: `anthropic.claude-haiku-4-5-20251001-v1:0`
   sólo soporta `INFERENCE_PROFILE`, no `ON_DEMAND`.

Los tres son ahora **checks** de `validate-all.sh`, así que no pueden volver en silencio.
