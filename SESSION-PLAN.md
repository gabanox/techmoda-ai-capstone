# Plan de sesiones y continuidad — TechModa AI Capstone (AIF-C01)

Cómo se imparte el capstone día por día, y **cómo se resuelve que el sandbox de
AWS re/Start es efímero** (se recicla entre sesiones).

## El problema de continuidad (y su solución)

El sandbox de re/Start (vocareum) **NO es persistente**: la sesión de lab dura
~4 horas y la cuenta se recicla. Entre un día y otro, el stack `techmoda-ai`, los
productos sembrados y todos los enriquecimientos (labels, sentimiento, audio)
**desaparecen**. Por eso una sesión NO puede asumir el estado de la anterior.

**Solución — bootstrap idempotente (paso 0 de cada sesión):**

```bash
bash scripts/bootstrap.sh
```

Eso reconstruye TODO el entorno de la Pista A en **~2-3 min**, sin importar si el
sandbox se recicló:
1. `sam build && sam deploy` de `template.sandbox.yaml` (Pista A, **sin CloudFront**
   para que levante rápido).
2. Re-siembra los 4 productos (`ai/seed/seed-products.sh`).
3. Imprime las Function URLs listas para usar.

Como **todo está en código** (template + seed + git), el sandbox efímero deja de
ser un problema — y es, de hecho, la lección cloud-native correcta: *cattle, not
pets*. El estudiante conserva su código (en el IDE/git); los datos se re-siembran.
Las sesiones de la Pista A son independientes entre sí (cada una agrega una
capacidad sobre los productos base), así que el bootstrap basta — no hay que
re-correr enriquecimientos previos.

## División por día (jornada 2 h · L–J · 5–7 p.m. hora Colombia)

> Dos pistas (ver `sessions/README.md`): **A** = hands-on del estudiante en el
> sandbox; **B** = demo guiada del instructor en la cuenta Bootcamp (Bedrock),
> que **sí es persistente** → no necesita bootstrap.

| Día | Sesiones | Pista | Entorno | Paso 0 |
|----|----------|-------|---------|--------|
| **D1** | S00 base · S01 Rekognition labels | A | Sandbox | `bash scripts/bootstrap.sh` |
| **D2** | S02 moderación · S03 Comprehend | A | Sandbox | `bash scripts/bootstrap.sh` (re-deploy + re-seed) |
| **D3** | S05 Polly · S10 gobernanza | A | Sandbox | `bash scripts/bootstrap.sh` |
| **D4** | S04 Translate · S06 Bedrock descripciones | B | Cuenta Bootcamp | (persistente) |
| **D5** | S07 RAG/embeddings · S08 chatbot | B | Cuenta Bootcamp | (persistente) |
| **D6** | S09 guardrails · S11 integración + demo + cleanup | B | Cuenta Bootcamp | (persistente) |

- **D1–D3 (Pista A):** cada día arranca con `bootstrap.sh`. Si el sandbox no se
  recicló (mismo día, dentro de la ventana de 4 h), `sam deploy` no detecta
  cambios y termina en segundos — el bootstrap es seguro de correr siempre.
- **D4–D6 (Pista B):** el instructor demuestra en la cuenta Bootcamp con Bedrock
  habilitado (verificado 2026-06-18, ver `sessions/README.md`). Al ser persistente,
  el embedding index de S07 sobrevive para S08; no hay reciclado.

## Día típico (Pista A, 2 h)

1. **Paso 0 — Bootstrap (~3 min):** `bash scripts/bootstrap.sh`. Deja el entorno
   como debe estar (aunque ayer se haya reciclado).
2. **Sesión 1 (~50 min):** seguir la `GUIA.md` de la sesión — concepto + agregar/probar
   la feature por su Function URL.
3. **Sesión 2 (~50 min):** la siguiente `GUIA.md`.
4. **Cierre:** los datos viven en el sandbox hasta el próximo reciclado; el código,
   en git. Mañana, el `bootstrap.sh` lo restituye.

## Verificación rápida del entorno

```bash
# ¿quedó todo arriba?
API=$(aws cloudformation describe-stacks --stack-name techmoda-ai --region us-east-1 \
       --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" --output text)
curl -s "${API%/}/products" | python3 -m json.tool   # debe listar los 4 productos
```
