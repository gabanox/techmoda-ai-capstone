#!/usr/bin/env bash
# S11 · Demo end-to-end de TechModa AI. Ejercita todas las features de IA en orden.
# Uso:  API_URL=https://xxxx.execute-api.us-west-2.amazonaws.com/Prod bash demo.sh
set -euo pipefail

STACK_NAME="${STACK_NAME:-techmoda-ai}"
REGION="${AWS_REGION:-us-west-2}"

if [[ -z "${API_URL:-}" ]]; then
  API_URL=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" \
    --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" --output text)
fi
[[ -z "$API_URL" || "$API_URL" == "None" ]] && { echo "✗ Definí API_URL"; exit 1; }

jqp() { python3 -m json.tool; }
hr() { printf '\n──────── %s ────────\n' "$1"; }

hr "0 · Catálogo (CRUD base S0)"
PID=$(curl -s "$API_URL/products" | python3 -c "import sys,json;print(json.load(sys.stdin)['products'][0]['productId'])")
echo "Usando productId=$PID"

hr "1 · Rekognition: etiquetas (requiere imageUrl real)"
curl -s -X POST "$API_URL/products/$PID/labels" | jqp || true

hr "2 · Rekognition: moderación + alt-text"
curl -s -X POST "$API_URL/products/$PID/moderate" | jqp || true

hr "3 · Comprehend: sentimiento"
curl -s -X POST "$API_URL/sentiment" -H "Content-Type: application/json" \
  -d '{"text":"Me encantó la calidad, llegó rapidísimo."}' | jqp || true

hr "4 · Translate: ES→EN"
curl -s -X POST "$API_URL/products/$PID/translate" -H "Content-Type: application/json" \
  -d '{"target":"en"}' | jqp || true

hr "5 · Polly: audio"
curl -s -X POST "$API_URL/products/$PID/voice" -H "Content-Type: application/json" \
  -d '{"lang":"es"}' | jqp || true

hr "6 · Bedrock: descripción generada"
curl -s -X POST "$API_URL/products/$PID/describe" -H "Content-Type: application/json" \
  -d '{"tone":"elegante","save":true}' | jqp || true

hr "7 · Bedrock embeddings: indexar + buscar"
curl -s -X POST "$API_URL/search/index" | jqp || true
curl -s "$API_URL/search?q=algo%20abrigado%20para%20el%20frio" | jqp || true

hr "8 · Bedrock RAG: asistente de compras"
curl -s -X POST "$API_URL/assistant" -H "Content-Type: application/json" \
  -d '{"message":"Busco algo cómodo y blanco para caminar"}' | jqp || true

hr "Demo completa ✓"
echo "Recordá el cleanup: bash scripts/delete-all.sh"
