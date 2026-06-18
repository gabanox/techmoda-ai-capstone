#!/bin/bash
#
# Deploy script for TechModa AI Capstone (sandbox AWS re/Start)
# Despliega el backend (Lambda + Function URLs + DynamoDB) sin API Gateway.
#
# Restricciones del sandbox (ver docs/SANDBOX-COMPAT.md): el LabRole no permite
# apigateway:* ni iam:CreateRole. Por eso NO se usa API Gateway y se necesita
# CAPABILITY_AUTO_EXPAND (Transform SAM) + CAPABILITY_IAM.
#

set -e

STACK_NAME="${STACK_NAME:-techmoda-ai}"
REGION="${AWS_REGION:-us-west-2}"

echo "Deploying SAM application (Function URLs, sin API Gateway)..."
echo "============================================================="
echo "  Stack:  $STACK_NAME"
echo "  Region: $REGION"
echo ""

echo "📦 sam build..."
sam build

echo "🚀 sam deploy..."
if [ -f "samconfig.toml" ]; then
    echo "📝 Usando configuración existente en samconfig.toml"
    sam deploy
else
    echo "⚠️  No hay samconfig.toml — desplegando con flags explícitos."
    sam deploy \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
        --resolve-s3 \
        --no-confirm-changeset \
        --no-fail-on-empty-changeset
fi

echo ""
echo "Deployment complete!"
echo "Revisá los Outputs (ApiUrl = Function URL del router) arriba."
