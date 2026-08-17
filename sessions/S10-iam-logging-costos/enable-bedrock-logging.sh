#!/usr/bin/env bash
# S10 · Habilita el "model invocation logging" de Amazon Bedrock a CloudWatch.
# Esto registra CADA invocación de modelo (prompt, respuesta, tokens) para auditoría
# y análisis de costos. Se configura UNA vez por cuenta/región.
#
# Requiere un rol que Bedrock pueda asumir para escribir en CloudWatch Logs.
# En el sandbox podés reusar LabRole como deliveryRole si tiene logs:PutLogEvents.
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
LOG_GROUP="${LOG_GROUP:-/techmoda/techmoda-ai/bedrock-invocations}"
ROLE_ARN="${ROLE_ARN:-arn:aws:iam::${ACCOUNT_ID}:role/LabRole}"

echo "→ Habilitando Bedrock invocation logging en ${REGION}"
echo "  log group: ${LOG_GROUP}"
echo "  delivery role: ${ROLE_ARN}"

aws bedrock put-model-invocation-logging-configuration \
  --region "$REGION" \
  --logging-config "{
    \"cloudWatchConfig\": {
      \"logGroupName\": \"${LOG_GROUP}\",
      \"roleArn\": \"${ROLE_ARN}\"
    },
    \"textDataDeliveryEnabled\": true,
    \"imageDataDeliveryEnabled\": false,
    \"embeddingDataDeliveryEnabled\": false
  }"

echo "✓ Logging habilitado. Verificá con:"
echo "  aws bedrock get-model-invocation-logging-configuration --region ${REGION}"
