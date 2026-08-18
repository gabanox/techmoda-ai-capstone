# IAM en TechModa AI — mínimo privilegio por función

> **Guía permanente.** Cada Lambda de este capstone declara sus propias `Policies:` y **SAM le crea
> un rol de ejecución de mínimo privilegio**. No hay rol preexistente que referenciar, ni account ID
> hardcodeado: el proyecto se despliega en cualquier cuenta AWS donde tengas `iam:CreateRole`.
>
> Esto es exactamente lo que evalúa el **dominio D5 del AIF-C01** (Security, Compliance & Governance).

---

## La regla de oro

**Mínimo privilegio = la acción mínima sobre el recurso más específico posible.**

Si el servicio soporta ARN de recurso, acotá por recurso. Si no lo soporta, acotá por **acción**.
Nunca `servicio:*` ni `Resource: "*"` por comodidad.

---

## Cómo se aplica en cada servicio

| Servicio | ¿Admite ARN de recurso? | Cómo lo acotamos |
|---|---|---|
| **DynamoDB** | ✅ Sí | `DynamoDBCrudPolicy` / `DynamoDBReadPolicy` **por tabla** |
| **S3** | ✅ Sí | `S3ReadPolicy` / `S3CrudPolicy` **por bucket** |
| **Bedrock** | ✅ Sí | `bedrock:InvokeModel` **por ARN de modelo** |
| **Rekognition** | ❌ No (APIs `Detect*`) | Por **acción** (`DetectLabels`, `DetectModerationLabels`) |
| **Comprehend** | ❌ No (APIs `Detect*`) | Por **acción** (`DetectSentiment` **+ `DetectDominantLanguage`**) |
| **Translate** | ❌ No | Por **acción** (`TranslateText` **+ `comprehend:DetectDominantLanguage`**, ver abajo) |
| **Polly** | ❌ No | Por **acción** (`SynthesizeSpeech`) |

Que Rekognition/Comprehend/Translate/Polly lleven `Resource: "*"` **no es descuido**: esas APIs no
tienen recurso al que apuntar. El límite real y defendible es la acción. Escribir `rekognition:*`
en cambio sí sería un error — daría acceso a colecciones de caras, streams, etc.

---

## El patrón (copiá esto para una función nueva)

```yaml
  MiFuncion:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: !Sub ${AWS::StackName}-MiFuncion
      CodeUri: sessions/SXX-.../functions/mi-funcion
      Handler: app.lambda_handler
      Runtime: python3.12
      Policies:
        # 1. Datos: acotado por TABLA. Read si solo lee, Crud si escribe.
        - DynamoDBCrudPolicy:
            TableName: !Ref ProductsTable
        # 2. Servicio de IA: acotado por ACCIÓN (esta API no admite ARN).
        - Statement:
            - Effect: Allow
              Action: servicio:AccionUnica
              Resource: "*"
      FunctionUrlConfig:            # HTTP sin API Gateway
        AuthType: NONE
        Cors:
          AllowOrigins: [ "*" ]
          AllowMethods: [ "*" ]
          AllowHeaders: [ "*" ]
```

**No pongas `Role:`.** `Role` y `Policies` son mutuamente excluyentes en SAM: si declarás `Role`,
SAM no crea nada y tus `Policies` se ignoran en silencio.

---

## Permisos por sesión

| Sesión | DynamoDB | Servicio de IA | Extra |
|---|---|---|---|
| S00 router | Crud | — | — |
| S01 labels | Crud | `rekognition:DetectLabels` | `s3:GetObject` si `imageUrl` es `s3://` |
| S02 moderación | Crud | `rekognition:DetectModerationLabels` + `DetectLabels` | idem |
| S03 sentimiento | Crud | `comprehend:DetectSentiment` + `comprehend:DetectDominantLanguage` | — |
| S04 traducción | Crud | `translate:TranslateText` + `comprehend:DetectDominantLanguage` | — |
| S05 voz | Crud | `polly:SynthesizeSpeech` | `S3CrudPolicy` sobre el bucket de audio |
| S06 descripciones | Crud | `bedrock:InvokeModel` | — |
| S07 index embeddings | Crud | `bedrock:InvokeModel` | — |
| S07 búsqueda | **Read** | `bedrock:InvokeModel` | — |
| S08 chatbot | **Read** | `bedrock:InvokeModel` | — |

S07-búsqueda y S08 llevan `Read` y no `Crud` porque solo consultan el catálogo. Es la diferencia
entre "acotado" y "acotado de verdad".

---

## El permiso que no se ve leyendo el código: dependencias downstream

**Acotá por las APIs que tu código llama, no por la que le da nombre a la sesión.** Dos casos reales de
este capstone, los dos descubiertos **recién al invocar en la nube** (`sam validate` y `sam build` pasan
igual, y el deploy también: el permiso que falta sólo aparece en la primera invocación).

**1. Un handler puede llamar más de una API.** S03 detecta el idioma **antes** de analizar el
sentimiento, así que necesita **dos** acciones:

```yaml
        - Statement:
            - Effect: Allow
              Action:
                - comprehend:DetectSentiment
                - comprehend:DetectDominantLanguage   # el handler detecta el idioma primero
              Resource: "*"
```

Con sólo `DetectSentiment`:
`AccessDeniedException ... not authorized to perform: comprehend:DetectDominantLanguage`.

**2. Un servicio puede llamar a OTRO servicio por dentro, con TU rol.** S04 usa
`SourceLanguageCode="auto"`, y Translate resuelve el idioma llamando a Comprehend:

```yaml
        - Statement:
            - Effect: Allow
              Action:
                - translate:TranslateText
                - comprehend:DetectDominantLanguage   # Translate lo llama por dentro si source=auto
              Resource: "*"
```

Sin ese permiso, el error **nombra un servicio que tu código nunca menciona**:

```
AccessDeniedException: com.amazonaws.translate.dataplane.DownstreamDependencyAccessDeniedException:
User: ...:assumed-role/techmoda-ai-TranslateCatalogFunctionRole-... is not authorized to perform:
comprehend:DetectDominantLanguage
```

**Cómo se caza esto** (y es la técnica que vale para el examen y para el trabajo): desplegá, invocá, y
leé CloudWatch. El mensaje de `AccessDenied` **siempre dice la acción exacta que falta** — es la forma
más rápida y honesta de construir una política mínima: empezar corto y agregar lo que el error pida,
en vez de arrancar con `servicio:*` y prometerse recortarlo después.

```bash
aws logs tail /aws/lambda/techmoda-ai-AnalyzeSentiment --since 10m --format short | grep -i denied
```

---

## Dos detalles de Bedrock que cuestan una tarde

**1. El ARN del modelo no lleva account, el del inference profile sí.**

```yaml
        - Statement:
            - Effect: Allow
              Action: bedrock:InvokeModel
              Resource:
                - !Sub arn:${AWS::Partition}:bedrock:*::foundation-model/*
                - !Sub arn:${AWS::Partition}:bedrock:*:${AWS::AccountId}:inference-profile/*
```

Los foundation models son públicos de AWS → su ARN tiene el campo de cuenta **vacío**
(`bedrock:us-east-1::foundation-model/...`). Los **inference profiles** (los IDs con prefijo `us.`,
que enrutan cross-region) viven en **tu** cuenta y su ARN sí la lleva. Si solo permitís
`foundation-model/*` y usás un ID `us.anthropic...`, te da `AccessDenied` y el mensaje no aclara
que el problema es el tipo de ARN.

**2. El permiso IAM no alcanza: hay que habilitar el modelo.**

`bedrock:InvokeModel` concedido + modelo no habilitado = `AccessDeniedException` **del lado del
servicio**. Andá a **Bedrock → Model access** en la consola, en **la región donde desplegás**
(es un setting por región), y habilitá los modelos que uses. Es el error más común de S06–S08.

---

## Verificar que quedó acotado

```bash
# Ninguna política debe usar comodín de servicio
grep -rn 'bedrock:\*\|rekognition:\*\|comprehend:\*\|polly:\*\|translate:\*\|dynamodb:\*' \
  template*.yaml sessions/*/template-snippet*.yaml     # -> sin resultados

# Ninguna función debe referenciar un rol preexistente
grep -rn 'Role:' template*.yaml sessions/*/template-snippet*.yaml   # -> sin resultados

# Y el chequeo completo del repo
bash scripts/validate-all.sh --static
```

Después del deploy, para ver el rol que SAM generó para una función:

```bash
aws lambda get-function-configuration \
  --function-name techmoda-ai-EnrichLabels --query Role --output text
# luego: aws iam list-role-policies --role-name <ese-rol>
```

---

## Gotcha de comodines en condiciones

Si usás condiciones IAM con `*` (por ejemplo para acotar por región `us-*`), usá **`StringLike` /
`ArnLike`**, nunca `StringEquals` / `ArnEquals`. Estos últimos tratan el `*` como carácter literal:
la política se crea **sin error** y deniega todo. Es un bug silencioso clásico y entra en el examen.

---

## Nota histórica

Versiones anteriores de este capstone estaban pensadas para el sandbox de AWS re/Start (Vocareum),
donde el `LabRole` no permite `iam:CreateRole`: todas las funciones reusaban ese rol amplio con
`Role: !Ref LabRoleArn` y **sin** `Policies:`, perdiendo el mínimo privilegio. Ese enfoque quedó
atrás — ahora el proyecto crea sus propios roles acotados y funciona en cualquier cuenta. El
historial de git conserva ambas variantes si querés compararlas como material didáctico.
