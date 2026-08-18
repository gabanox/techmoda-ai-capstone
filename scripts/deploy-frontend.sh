#!/bin/bash
set -e

# Get stack name from samconfig.toml or use default
STACK_NAME="techmoda-ai"
if [ -f "samconfig.toml" ]; then
    STACK_NAME=$(grep 'stack_name' samconfig.toml | cut -d'"' -f2 || echo "techmoda-ai")
fi

echo "Deploying frontend to S3..."

# Get bucket name from CloudFormation outputs
BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --query 'Stacks[0].Outputs[?OutputKey==`FrontendBucketName`].OutputValue' \
    --output text)

if [ -z "$BUCKET_NAME" ]; then
    echo "Error: Could not find frontend bucket. Deploy the SAM template first."
    exit 1
fi

# Get API URL
API_URL=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --query 'Stacks[0].Outputs[?OutputKey==`ApiUrl`].OutputValue' \
    --output text)

echo "Bucket: $BUCKET_NAME"
echo "API URL: $API_URL"
echo ""

# Inject runtime environment configuration
echo "🔧 Injecting runtime configuration..."
./scripts/inject-env.sh --api-url "$API_URL" --dist-dir frontend/dist
echo ""

# Sync to S3.
#
# --delete borra del bucket todo lo que no esté en frontend/dist/, que es lo que
# queremos para los bundles con hash (si no, se acumulan para siempre). Pero las
# fotos de producto que el estudiante sube para S1/S2 tampoco están en dist/, así
# que sin la exclusión este sync SE LAS LLEVA y las sesiones de visión se rompen
# en silencio en el próximo deploy del frontend.
#
# Por eso las imágenes de producto viven en product-images/ y no en assets/:
# assets/ es la salida de Vite, y ahí sí tiene que mandar --delete.
aws s3 sync frontend/dist/ s3://$BUCKET_NAME/ --delete --exclude "product-images/*"

echo ""
echo "Frontend deployed successfully!"
echo "CloudFront URL: https://$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --query 'Stacks[0].Outputs[?OutputKey==`FrontendUrl`].OutputValue' \
    --output text | sed 's/https:\/\///')"
