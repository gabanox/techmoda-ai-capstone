> ⚠️ **Pista B — Demo guiada del instructor.** Esta sesión usa Bedrock/Translate y
> **NO corre en el sandbox AWS re/Start**: el `LabRole` deniega `bedrock:InvokeModel` /
> `translate:TranslateText` y no es modificable. Se ejecuta en una cuenta AWS de Bootcamp
> con Bedrock habilitado y un rol con esos permisos. Ver `sessions/README.md` (dos pistas)
> y `docs/SANDBOX-COMPAT.md` (matriz de servicios).

# S4 · Catálogo multilingüe ES↔EN (Amazon Translate)

**Duración:** ~60 min · **Servicio:** Amazon Translate · **Dominio AIF-C01:** **D1 — Fundamentals of AI and ML (20%)**

> 🏖️ **Sandbox:** esta función se expone con su propia **Lambda Function URL** (no API Gateway) y usa el
> **LabRole** — ver [`docs/SANDBOX-COMPAT.md`](../../docs/SANDBOX-COMPAT.md). Su URL es el output
> **`TranslateCatalogUrl`** del stack.

---

## 🎯 Objetivo

Que TechModa venda en dos idiomas **sin contratar traductores**. Con un endpoint traducimos el `name` y la
`description` de cada producto entre español e inglés y guardamos ambas versiones, listas para que el
frontend muestre el catálogo según el idioma del visitante.

---

## 🧩 Prerequisitos

- **S0 desplegado**, con productos cargados (cada uno con `name` y `description`).

---

## 🧠 El concepto: traducción automática neuronal (NMT)

Amazon Translate es un modelo de **traducción automática neuronal** preentrenado. Detecta el idioma de
origen (`SourceLanguageCode="auto"`, que internamente usa Comprehend) y produce la traducción al idioma
destino. De nuevo: **solo inferencia, cero entrenamiento**.

Ideas que el examen evalúa:

- **Servicio por modalidad/tarea:** traducir texto → Translate. No uses Bedrock para una traducción simple
  (sería más caro y menos determinista). *Elegir la herramienta adecuada al costo/precisión es parte del examen.*
- **Composición de servicios:** Translate se apoya en Comprehend para autodetectar el idioma — por eso la
  política IAM incluye `comprehend:DetectDominantLanguage`.
- **Localización ≠ solo traducir.** Translate no adapta moneda, formato de talla, ni tono cultural; eso es
  responsabilidad del producto. El examen distingue **capacidades reales vs. expectativas mágicas**.

---

## 🚶 Paso a paso

1. Pegá `TranslateCatalogFunction` (con `Role: !Ref LabRoleArn` + su `FunctionUrlConfig`) y el output `TranslateCatalogUrl` desde el snippet.
2. `sam build && sam deploy`.
3. Traducí un producto al inglés (Function URL de esta función; el productId va en path o body):
```bash
URL=$(aws cloudformation describe-stacks --stack-name techmoda-ai --region us-west-2 \
  --query "Stacks[0].Outputs[?OutputKey=='TranslateCatalogUrl'].OutputValue" --output text)
curl -s -X POST "${URL%/}/products/PRODUCT_ID/translate" \
  -H "Content-Type: application/json" -d '{"target":"en"}' | python3 -m json.tool
```
Respuesta esperada:
```json
{
  "productId": "a1b2...",
  "target": "en",
  "translation": {
    "name": "Floral midi dress",
    "description": "Chiffon midi dress with floral print, short sleeve."
  }
}
```
4. Verificá en DynamoDB el mapa anidado `translations.en`.

---

## 🔐 Mínimo privilegio

Solo `translate:TranslateText` (+ `comprehend:DetectDominantLanguage` para el `auto`), y CRUD de la tabla.

---

## ✅ Checklist de validación

- [ ] La traducción ES→EN devuelve texto coherente.
- [ ] Probá `{"target":"es"}` sobre un producto en inglés y vuelve al español.
- [ ] El producto en DynamoDB guarda `translations.en` y/o `translations.es`.
- [ ] Idea de mejora: el frontend lee `translations.<lang>` según el idioma del navegador.

---

## 📝 Qué entra en el examen (D1)

- **Amazon Translate** como servicio de IA administrado para traducción.
- Elegir Translate vs. Bedrock para una tarea acotada (**costo/latencia/determinismo**).
- Servicios de IA que **se componen** (Translate + Comprehend).
- Diferencia entre **traducción** y **localización** (alcance real del servicio).

---

## 💸 Costo + 🧹 Cleanup

**Costo:** Translate se cobra **por carácter traducido**, con una **capa gratuita** durante los primeros
meses (verificar vigencia). Traducir un catálogo de práctica son **centavos**. *Verificar en la página de
precios de Amazon Translate.*

**Cleanup de S4:** quitar `TranslateCatalogFunction` + ruta del `template.yaml` y `sam deploy`.
