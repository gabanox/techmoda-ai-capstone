# TechModa AI Capstone — Mapa de sesiones (AIF-C01)

Capstone de **AWS Certified AI Practitioner (AIF-C01)** construido sobre un catálogo
serverless de moda. Cada sesión es atómica (~1 h) y suma una capacidad de IA.

## Dos pistas (por qué)

El sandbox de **AWS re/Start (vocareum)** ejecuta todo con el `LabRole`, que trae
`ReadOnlyAccess` + `VocLabPolicy`. Empíricamente (verificado 2026-06-18, cuenta
`879652687082`) eso **permite** las acciones "read" de los servicios de IA gestionados
(Rekognition, Comprehend, Polly) pero **deniega** `bedrock:InvokeModel` y
`translate:TranslateText`, y el LabRole **no se puede modificar** (sin `iam:CreateRole`).

Por eso el capstone se organiza en dos pistas:

- **Pista A — Hands-on del estudiante (corre en el sandbox re/Start).**
  IA aplicada con **servicios gestionados**. Mapea al **Dominio 1 del AIF-C01**
  (Fundamentals of AI/ML → "servicios de IA gestionados").
- **Pista B — Demo guiada del instructor (cuenta AWS de Bootcamp con Bedrock).**
  IA **generativa** (Bedrock, RAG, guardrails) + Translate. Mapea a los **Dominios 2–5**.
  No corre en el sandbox; el instructor la demuestra en una cuenta Bootcamp donde
  Bedrock está habilitado (la misma plataforma del LMS ya usa Bedrock).

## Tabla de sesiones

| Sesión | Capacidad | Servicio AWS | Pista | Dominio AIF-C01 | Sandbox re/Start |
|---|---|---|---|---|---|
| **S00** Base | Catálogo CRUD serverless | Lambda + DynamoDB + S3/CloudFront | A | Base (lienzo) | ✅ Corre |
| **S01** Etiquetado | Auto-labels de imágenes | Rekognition `DetectLabels` | A | D1 | ✅ Corre |
| **S02** Moderación | Moderación + alt-text accesible | Rekognition `DetectModerationLabels` | A | D1 · D4 | ✅ Corre |
| **S03** Sentimiento | Análisis de reseñas | Comprehend | A | D1 | ✅ Corre |
| **S05** Voz | Fichas habladas | Polly | A | D1 | ✅ Corre |
| **S10** Gobernanza | Logging de invocaciones + tags de costo | CloudWatch Logs / IAM | A | D5 | ✅ Corre |
| **S04** Multilingüe | Catálogo traducido | Translate | **B** | D1 | ❌ LabRole deniega `translate:TranslateText` |
| **S06** Descripciones | Texto generado por IA | Bedrock | **B** | D2 · D3 | ❌ LabRole deniega `bedrock:InvokeModel` |
| **S07** Búsqueda RAG | Embeddings + búsqueda semántica | Bedrock (Titan Embeddings) | **B** | D3 | ❌ idem |
| **S08** Chatbot | Asistente de compras (RAG) | Bedrock | **B** | D3 | ❌ idem |
| **S09** Guardrails | Filtros de contenido / sesgo | Bedrock Guardrails | **B** | D4 | ❌ depende de Bedrock |
| **S11** Integración | Demo end-to-end + cleanup | — | A+B | Cierre | ✅ Pista A / 🎥 Pista B demo |

## Cómo correr cada pista

### Pista A — sandbox AWS re/Start
```bash
# 1. Desplegar base + features de servicios gestionados
sam build -t template.full.yaml
sam deploy -t template.full.yaml --stack-name techmoda-ai --region us-west-2 \
  --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND --resolve-s3 --no-confirm-changeset
# 2. Sembrar productos
bash ai/seed/seed-products.sh
# 3. Ejercitar (las features de Pista A responden; las de Pista B devuelven AccessDenied)
bash sessions/S11-integracion-demo-cleanup/demo.sh
```
Para S01/S02 (visión) hay que subir una imagen real a `s3://techmoda-ai-frontend/assets/`
y apuntar el `imageUrl` del producto a esa ruta (`s3://...`).

### Pista B — demo del instructor (cuenta AWS Bootcamp con Bedrock)
Requiere una cuenta donde:
1. **Bedrock model access** esté habilitado en la región (Claude Haiku + Titan Embeddings).
2. El rol de ejecución de las Lambdas permita `bedrock:InvokeModel`, `translate:TranslateText`
   y (para S09) `bedrock:CreateGuardrail`/`ApplyGuardrail`.

En una cuenta propia se reemplaza `Role: !Ref LabRoleArn` por un rol con políticas de
mínimo privilegio acotadas por acción/ARN (ver `docs/SANDBOX-COMPAT.md` y el historial git
para el patrón de `Policies:` por función). El instructor demuestra S04 y S06–S09 ahí.

## Estado verificado (2026-06-18)

Desplegado y probado endpoint-por-endpoint en el sandbox `879652687082`:
Pista A (S00, S01, S02, S03, S05, S10) **funciona** end-to-end; Pista B (S04, S06–S09)
**bloqueada por el LabRole** como se documenta arriba. Detalle de la matriz empírica de
servicios en `docs/SANDBOX-COMPAT.md`.

## Verificación Pista B en cuenta Bootcamp (2026-06-18)

Las sesiones de Bedrock/Translate, bloqueadas en el sandbox re/Start, fueron
verificadas en la cuenta AWS de Bootcamp Institute (`281248178297`, us-east-1),
que sí tiene Bedrock habilitado:

| Sesión | Capacidad | Resultado |
|---|---|---|
| S04 | `translate:TranslateText` | ✅ traducción correcta ES→EN |
| S06 | Bedrock Converse `anthropic.claude-3-haiku-20240307-v1:0` | ✅ descripción generada |
| S07/S08 | Bedrock `amazon.titan-embed-text-v2:0` (InvokeModel) | ✅ embedding de 1024 dims |
| S09 | Bedrock Guardrails | ✅ API con acceso |

Conclusión: la Pista B funciona end-to-end en una cuenta con Bedrock habilitado y
un rol de ejecución con `bedrock:InvokeModel`/`translate:TranslateText`. En el
sandbox re/Start no corre por la política del LabRole (ver matriz en
`docs/SANDBOX-COMPAT.md`), por eso se imparte como demo guiada del instructor.
