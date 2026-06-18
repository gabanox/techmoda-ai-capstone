# Compatibilidad con el sandbox AWS re/Start (Vocareum)

> **Guía permanente.** Todo recurso de este capstone debe poder desplegarse con el
> **LabRole** del sandbox AWS re/Start. Este documento fija las 3 restricciones que
> moldean la arquitectura y cómo las resolvemos. Si agregás una sesión o función
> nueva, seguí este patrón.

## TL;DR

| # | Restricción del sandbox | Síntoma si lo ignorás | Solución adoptada |
|---|---|---|---|
| 1 | **No API Gateway** (`apigateway:*` denegado) | `403 ... no identity-based policy allows the apigateway:POST action` y **el stack entero revierte** | **Lambda Function URLs** (`AuthType: NONE`, CORS abierto). El CRUD usa **un router** con **una** Function URL; cada función IA HTTP tiene la suya. |
| 2 | **No `iam:CreateRole`** | SAM no puede auto-generar el rol de ejecución de la función → falla el deploy | Cada `AWS::Serverless::Function` referencia el **LabRole** preexistente vía `Role:`. **Se elimina `Policies:`** (Role y Policies son mutuamente excluyentes en SAM). |
| 3 | **Servicios IA permitidos** | — | `rekognition`, `comprehend`, `textract`, `polly`, `transcribe`, `translate`, `bedrock`, además de `lambda:*`, `dynamodb:*`, S3, `cloudfront:*`, `logs`, `ssm`, `sns`, `sqs`. El LabRole ya los trae; no hace falta IAM extra. |

El deploy lo ejecuta el **LabRole** de la EC2 del sandbox:
`arn:aws:iam::879652687082:role/LabRole` (parámetro `LabRoleArn` en los templates).

---

## 1. Sin API Gateway → Lambda Function URLs

`AWS::Serverless::Api` (y los `Events: Type: Api`) requieren `apigateway:POST`, que el
LabRole **no** permite. Como SAM crea la API durante el deploy, el `CREATE_FAILED`
**revierte todo el stack**. En su lugar exponemos las funciones con **Lambda
Function URLs**, que sí están permitidas (`lambda:CreateFunctionUrlConfig`).

### Arquitectura elegida para el CRUD: **un router, una Function URL**

```
                 Lambda Function URL (AuthType: NONE, CORS *)
                 https://<id>.lambda-url.us-west-2.on.aws/
                                  │
                                  ▼
                    functions/router/index.js      ← parsea method + rawPath
                ┌───────────┬─────────┴────┬───────────┬───────────┐
                ▼           ▼              ▼           ▼           ▼
          list-items   create-item     get-item   update-item  delete-item   (require '../')
```

**Por qué un router y no 5 Function URLs:**

1. **El frontend no cambia de lógica.** `frontend/src/lib/api.ts` ya arma rutas como
   `${API_URL}/products` y `${API_URL}/products/{id}`. Con **una** base URL apuntando
   al router, esas rutas funcionan tal cual. Cinco URLs obligarían a mapear cada
   operación a una URL distinta en el frontend.
2. **Reutiliza la lógica existente sin duplicar.** El router se empaqueta con
   `CodeUri: functions/` + `Handler: router/index.handler`, así que puede
   `require('../list-items/index.js')` etc. — los 5 handlers CRUD probados se ejecutan
   sin tocar su código.
3. **Una sola URL para inyectar/operar.** Menos outputs, menos variables de entorno.

El router lee el evento de **Function URL (payload v2.0)**:
`event.requestContext.http.method`, `event.rawPath`, `event.body` (decodifica base64
si `isBase64Encoded`), normaliza dobles slash, y reconstruye `pathParameters.id` para
reusar los handlers.

### Funciones de IA

- **HTTP on-demand** (S1 labels, S2 moderate, S3 sentiment, S4 translate, S5 voice,
  S6 describe, S7 index/search, S8 assistant) → **cada una con su propia Function URL**.
  Se agregan sesión por sesión sin tocar el router. Los handlers Python extraen el
  `productId` del `rawPath` (`/products/<id>/...`) o del body, así funcionan igual con
  Function URL que con API Gateway.
- **Event-driven** (p. ej. Rekognition disparado por **subida de imagen a S3** →
  evento S3, no HTTP) → **mantener el trigger de evento** (`Events: Type: S3`), sin
  Function URL. *(En el diseño actual ninguna función es S3-event-driven; todas son
  on-demand. Si agregás una, no le pongas Function URL.)*

### Patrón de recurso (copiá esto)

```yaml
  MiFuncion:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: !Sub ${AWS::StackName}-MiFuncion
      CodeUri: sessions/SXX-.../functions/mi-funcion
      Handler: app.lambda_handler
      Runtime: python3.12
      Role: !Ref LabRoleArn          # ← regla #2
      FunctionUrlConfig:             # ← regla #1
        AuthType: NONE
        Cors:
          AllowOrigins: [ "*" ]
          AllowMethods: [ "*" ]
          AllowHeaders: [ "*" ]
```

Y el output para obtener la URL (SAM crea el recurso `<LogicalId>Url`):

```yaml
Outputs:
  MiFuncionUrl:
    Value: !GetAtt MiFuncionFunctionUrl.FunctionUrl   # nota: <LogicalId> + "Url"
```

---

## 2. Sin `iam:CreateRole` → reusar el LabRole

`Policies:` en SAM se traduce a un rol IAM **nuevo** por función. El LabRole no puede
crear roles, así que falla. Reglas:

- **`Role: !Ref LabRoleArn`** en **cada** `AWS::Serverless::Function`
  (a nivel de cada función, **NO** en `Globals.Function` — SAM no soporta `Role` ahí;
  rompe con `InvalidSamDocumentException`).
- **Eliminar `Policies:`** de cada función. `Role` y `Policies` son **mutuamente
  excluyentes** en SAM.
- El LabRole ya es de permisos amplios, así que no perdemos funcionalidad. *(En una
  cuenta propia sí escribirías políticas de mínimo privilegio — el historial de git
  conserva esas versiones acotadas por acción/ARN, útiles como material didáctico de
  buenas prácticas IAM.)*

`LabRoleArn` es un `Parameter` con default `arn:aws:iam::879652687082:role/LabRole`.
Para otra cuenta: `--parameter-overrides LabRoleArn=arn:aws:iam::<acct>:role/LabRole`.

---

## 3. Servicios de IA permitidos

El LabRole permite los servicios de IA administrados que usa el capstone, sin IAM
adicional: **Rekognition** (S1/S2), **Comprehend** (S3), **Translate** (S4),
**Polly** (S5), **Bedrock** (S6/S7/S8). Además: `lambda:*` (incl.
`CreateFunctionUrlConfig`), `dynamodb:*`, S3 (bucket/objeto), `cloudfront:*`, `logs`,
`ssm`, `sns`, `sqs`.

> **Bedrock**: habilitá el acceso a cada modelo en **Bedrock → Model access**
> (región `us-west-2`) antes de invocar, o `InvokeModel` devolverá AccessDenied del
> lado del servicio aunque el IAM lo permita.

---

## Deploy en el sandbox

```bash
cp samconfig.us-west-2.example samconfig.toml      # stack techmoda-ai, us-west-2
sam build
sam deploy --stack-name techmoda-ai --region us-west-2 \
  --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
  --resolve-s3 --no-confirm-changeset
```

`CAPABILITY_AUTO_EXPAND` es obligatorio (Transform SAM). No hace falta crear roles
nuevos (regla #2), pero se incluye `CAPABILITY_IAM` por compatibilidad del changeset.

Atajo: `./scripts/deploy.sh` (build + deploy con estas flags).

### Verificación post-deploy

```bash
# Base API (router CRUD)
API=$(aws cloudformation describe-stacks --stack-name techmoda-ai \
       --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" --output text)
curl "${API%/}/products"                       # -> {"products":[...]}
curl -X POST "${API%/}/products" -H 'Content-Type: application/json' \
     -d '{"name":"Test","price":10}'
```

---

## Checklist antes de mergear una sesión nueva

- [ ] La función tiene `Role: !Ref LabRoleArn` (no `Policies:`).
- [ ] Si es HTTP: tiene `FunctionUrlConfig` (no `Events: Type: Api`, no `RestApiId`).
- [ ] Si es event-driven: tiene su trigger (`Events: Type: S3/SQS/...`), sin Function URL.
- [ ] No hay ningún `AWS::Serverless::Api` ni `apigateway:` en el template/snippet.
- [ ] El handler extrae sus parámetros del `rawPath`/`queryStringParameters`/body
      (no asume `pathParameters` de API Gateway).
- [ ] `sam validate --lint` pasa para `template.yaml` y `template.full.yaml`.
