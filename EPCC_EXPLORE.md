# Exploración: TechModa AI Capstone (codebase completo)

**Fecha**: 2026-08-17 · **Alcance**: Medium · **Estado**: ✅ Completa
**Rama**: `master` · **Commit**: `aa224d0` · **Working tree**: limpio (antes de esta exploración)

---

## 1. Foundation (qué existe)

**Propósito**: material educativo (Bootcamp Institute / AWS re/Start, pista **AI Practitioner
AIF-C01**). Un catálogo de e-commerce serverless al que se le agregan capacidades de IA de AWS, una
sesión de ~1 h a la vez (`sessions/S00..S11`). No es un producto: es un lienzo pedagógico.

**Stack**:
- IaC: **AWS SAM** (`Transform: AWS::Serverless-2016-10-31`), región fija `us-east-1`, stack `techmoda-ai`
- CRUD: **Node.js 22** + `@aws-sdk/client-dynamodb` / `lib-dynamodb` (`functions/`)
- IA: **Python 3.12** + boto3 (`sessions/S0X-*/functions/*/app.py`)
- Frontend: **React 18 + Vite 5 + TS 5.5 + Tailwind 3**, tests con **Vitest 1 + Testing Library** (`frontend/`)
- Datos: **DynamoDB** `${StackName}-Products`, PK `productId` (S), `PAY_PER_REQUEST`

**Entry points**: `functions/router/index.js` (router CRUD, `Handler: router/index.handler`,
`CodeUri: functions/`) · un `app.py::lambda_handler` por feature de IA · `frontend/src/main.tsx`.

**Instrucciones de proyecto (`CLAUDE.md`, raíz)**: existe y es reciente (creado en esta sesión). Fija:
docs en **español**, código en inglés; `Role: !Ref LabRoleArn` sin `Policies:`; Function URLs en vez de
API Gateway; el gotcha de `Decimal` en DynamoDB; y la advertencia de no "arreglar" los denies de IAM de
la Pista B. No hay `.claude/CLAUDE.md` ni `~/.claude/CLAUDE.md`.

---

## 2. Patterns (cómo está construido)

**Una Lambda = un servicio de IA.** Patrón dominante y explícito del capstone. Cada `app.py` sigue la
misma forma (ver referencia en `sessions/S01-rekognition-labels/functions/enrich-labels/app.py`):

1. Config por variables de entorno con default (`MIN_CONFIDENCE`, `BEDROCK_MODEL_ID`, `TOP_K`…)
2. Clientes boto3 y `table` a nivel de módulo (se reusan entre invocaciones en caliente)
3. `_path_id(event)` — extrae `productId` de `rawPath`, con fallback a `pathParameters` / query / body
4. Leer producto → llamar servicio de IA → `update_item` con el resultado → responder
5. `_response(status, body)` con CORS `*` y `ensure_ascii=False`

**Códigos de estado consistentes** en los handlers de IA: `400` falta id · `404` producto inexistente ·
`422` dato de entrada inválido (p. ej. `imageUrl` sin reemplazar) · `502` falló el servicio de IA.

**Router en vez de API Gateway** (`functions/router/index.js`): parsea payload v2.0 de Function URL
(`requestContext.http.method`, `rawPath`, body base64), normaliza `//`, reconstruye `pathParameters.id`
y hace `require('../list-items')` para reusar los 5 handlers CRUD sin duplicar lógica.

**Config runtime del frontend** (`docs/RUNTIME_CONFIG.md`): `env-config.js.template` con token
`%%VITE_API_URL%%` → `scripts/inject-env.sh` lo reemplaza post-build → `window.__ENV`. Resolución en
`frontend/src/lib/api.ts:19-24`: `window.__ENV` → `import.meta.env` → placeholder. Permite cambiar la
API sin rebuild.

**Testing**: solo frontend. 4 archivos, **88 casos** (`ProductModal` 35, `ProductCard` 24,
`useProducts` 16, `api` 13), jsdom + `src/test/setup.ts` + `src/test/mockData.ts`. **No hay tests de
Python**: las Lambdas de IA se validan con el `curl` de cada `GUIA.md` y con
`sessions/S11-*/demo.sh`. No hay CI (`.github/` no existe).

**Documentación como producto**: ~4.000 líneas en `docs/` + una `GUIA.md` por sesión con estructura
fija (objetivo → concepto → qué entra en el examen → paso a paso → checklist → costo + cleanup).
`docs/specs/` (5 specs CRUD) y `docs/prompts/` (6 guías de prompting) son andamiaje del capstone base.

---

## 3. Constraints (qué limita las decisiones)

Las dos restricciones que **explican todo el diseño** (`docs/SANDBOX-COMPAT.md`):

| # | Restricción del sandbox Vocareum | Consecuencia |
|---|---|---|
| 1 | `apigateway:*` denegado | Sin API Gateway → **Lambda Function URLs** (`AuthType: NONE`, CORS `*`). Un `CREATE_FAILED` revertía el stack entero. |
| 2 | `iam:CreateRole` denegado | `Role: !Ref LabRoleArn` en cada función; **nunca `Policies:`** (excluyentes en SAM) ni `Role` en `Globals.Function` (rompe con `InvalidSamDocumentException`). |

**Matriz IAM empírica** (verificada 2026-06-18, cuenta `879652687082`): Rekognition, Comprehend, Polly,
S3, DynamoDB ✅ · **Translate y Bedrock ❌** (`AccessDeniedException` por política del `LabRole`, que no
es modificable). De ahí las **dos pistas**: A (S00, S01–S03, S05, S10) corre en el sandbox; B (S04,
S06–S09) se demuestra en la cuenta Bootcamp `281248178297`.

**Sandbox efímero**: la sesión de lab dura ~4 h y la cuenta se recicla. Ninguna sesión asume el estado
de la anterior; `scripts/bootstrap.sh` reconstruye todo (deploy de `template.sandbox.yaml` + re-seed) en
2–3 min, idempotente. Es la lección cloud-native deliberada: *cattle, not pets* (`SESSION-PLAN.md`).

**Seguridad — no implementada a propósito** (`docs/ARCHITECTURE.md:771-779`): `AuthType: NONE` (27
ocurrencias), CORS `*`, sin API keys / SigV4 / Cognito. El único documento de política real que el
proyecto crea es el bucket policy público del frontend; el bucket de audio de S05 va con
`PublicAccessBlock` en `true` + URL prefirmada (`synthesize-voice/app.py:101`).

**FinOps**: regla explícita de no dejar recursos de IA encendidos entre sesiones. Cada `GUIA.md` cierra
con estimación de costo *marcada para verificar contra precios oficiales* y su cleanup.
`LifecycleConfiguration ExpirationInDays: 7` en el bucket de audio; `RetentionInDays: 30` en el log group
de Bedrock.

---

## 4. Reusability (qué aprovechar)

**Para agregar una sesión nueva**, el patrón está listo para copiar:
`sessions/S01-*/` es la referencia completa (GUIA + `functions/<name>/app.py` + `requirements.txt` +
`template-snippet.yaml`). El snippet de S05 es el ejemplo a seguir cuando la sesión agrega **recursos
propios** además de la Lambda (bucket + lifecycle).

**Tres templates, elegir según el caso**: `template.yaml` (solo S0, para pegar snippets
progresivamente) · `template.sandbox.yaml` (Pista A sin CloudFront, lo que usa `bootstrap.sh`) ·
`template.full.yaml` (base + S1–S8 + gobernanza, validado con `sam validate --lint`).

**Duplicación medida**: `_response()` está reescrito en **9 de 9** handlers de IA y el helper de
extracción de id en **5**. `README.md:207` documenta un `ai/shared/` "helpers reutilizables" que **no
existe** — solo hay `ai/seed/`. La duplicación no es accidental: es el hueco que ese directorio iba a
llenar. (Nota pedagógica en tensión: para un capstone donde cada sesión debe leerse aislada, el copy-paste
puede ser intencional — conviene confirmarlo antes de refactorizar.)

---

## 5. Hallazgos que afectan decisiones

**🔴 Contrato roto frontend ↔ backend (no documentado en ningún lado).** El frontend usa **snake_case**
y el backend **camelCase**, y `api.ts` **no hace ningún mapeo** (devuelve `data.products` y
`response.json()` crudos):

| | Frontend | Backend |
|---|---|---|
| id | `product_id` (`types.ts:2`, `ProductCard.tsx:51`, `useProducts.ts:40,54`) | `productId` (`template.yaml:41`, `create-item/index.js:42`) |
| imagen | `image_url` (`ProductCard.tsx:16`) | `imageUrl` (`create-item/index.js:47`, seed) |
| fechas | `created_at` / `updated_at` | `createdAt` / `updatedAt` |
| `stock` | en el tipo `Product` | **no se persiste** (`create-item` no lo incluye) |

Impacto en runtime: `product.image_url` → `undefined` (imagen rota) y `product.product_id` →
`undefined` (borrar/editar con id undefined). Al crear, `create-item` arma un objeto explícito, así que
un POST con `image_url` guarda `imageUrl: ''` **sin error** — la imagen se pierde en silencio.

Los 88 tests pasan porque `src/test/mockData.ts` replica el contrato equivocado: validan el mock, no la
API. `VALIDATION_REPORT.md` (780 líneas) no lo menciona.

**Origen probable**: `frontend/.bolt/config.json` → `bolt-vite-react-ts`, y `types.ts:13-24` exporta un
tipo `Database` con forma de **Supabase** (`public.Tables.products.Row/Insert/Update`) que nada usa.
Residuo del starter, nunca reconciliado con DynamoDB.

**🟡 Doc que contradice al código**: `docs/ARCHITECTURE.md:753-759` ("Privilegio Mínimo IAM: cada Lambda
tiene solo los permisos que necesita, sin ARNs comodín") describe el capstone base, no la realidad del
`LabRole` que el mismo archivo documenta en las líneas 211-229.

**🟡 Model ID de Bedrock vencido**: default pineado
`anthropic.claude-3-haiku-20240307-v1:0` (`template.full.yaml:181,244` + defaults en S06/S08). Es un ID
de la integración legacy de Bedrock y corresponde a Claude 3 Haiku, con retiro anunciado para
**2026-04-19** — ya pasó. Va por env var y S06 usa la **Converse API** (agnóstica al proveedor), así que
cambiarlo no requiere tocar código. Primer sospechoso si una demo de Pista B falla con "model not found".

**🟢 Gotcha ya resuelto y documentado**: DynamoDB no acepta `float` vía el resource de boto3 → los
`Confidence` de Rekognition van como `Decimal(str(v))` (`enrich-labels/app.py:118-121`). Aplica a
cualquier handler nuevo que persista números de un servicio de IA.

---

## 6. Handoff

**Para PLAN**: la restricción dura es el `LabRole` — cualquier plan que requiera API Gateway, roles
nuevos, Bedrock o Translate **en el sandbox** es inviable por diseño, no por implementación. El hallazgo
🔴 es el candidato más claro a próximo trabajo: es un defecto real, silencioso, con impacto en la demo
del estudiante, y el fix tiene dos caminos con consecuencias distintas (mapear en `api.ts` vs. renombrar
el tipo del frontend a camelCase).

**Para CODE**: leer `docs/SANDBOX-COMPAT.md` antes de agregar funciones; checklist "antes de mergear" al
final de ese archivo. Handler nuevo → copiar la forma de `enrich-labels/app.py`. Recurso nuevo →
`template-snippet.yaml` con `Role: !Ref LabRoleArn` + `FunctionUrlConfig`, y output
`!GetAtt <LogicalId>FunctionUrl.FunctionUrl`.

**Para COMMIT**: `sam validate --lint` en `template.yaml` **y** `template.full.yaml`; en `frontend/`,
`npm run lint && npm run typecheck && npx vitest run`. No hay CI: las verificaciones son manuales. No hay
umbral de cobertura configurado (`@vitest/coverage-v8` está instalado, `test:coverage` existe).

**Gaps / a validar con el dueño del repo**:
- ¿La duplicación de `_response`/`_path_id` es intencional (cada sesión autocontenida) o es deuda?
  Determina si `ai/shared/` debe crearse o si `README.md:207` debe corregirse.
- ¿El `Database` type de Supabase se borra o quedó por alguna razón?
- No pude verificar nada contra AWS en vivo (sin credenciales activas en este entorno): la matriz IAM y
  los estados de despliegue se toman de `docs/SANDBOX-COMPAT.md` y `sessions/README.md`, fechados
  2026-06-18.

---

## Nota sobre el plugin EPCC

`commands/epcc-explore.md` referencia `@../docs/EPCC_BEST_PRACTICES.md`, pero el plugin instalado solo
trae `agents/`, `commands/` y `hooks/` — no hay `docs/`. Esa guía nunca se carga; el resto del comando
funciona igual. No creé `epcc-progress.md` porque no existía (el tracking de proyecto largo es opcional).

**Próxima fase sugerida**: `/epcc-workflow:epcc-plan alinear el contrato de campos frontend ↔ DynamoDB`
