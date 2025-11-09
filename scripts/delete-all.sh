#!/bin/bash
#
# Delete ALL script for TechModa Serverless Capstone
# This script deletes the entire CloudFormation stack (Backend + Frontend)
#

set -e

echo "=========================================="
echo "  TechModa - Eliminar Recursos"
echo "=========================================="
echo ""

# Get stack name from samconfig.toml or use default
STACK_NAME="techmoda-capstone"
if [ -f "samconfig.toml" ]; then
    STACK_NAME=$(grep 'stack_name' samconfig.toml | cut -d'"' -f2 || echo "techmoda-capstone")
fi

# Check if stack exists
echo "🔍 Verificando si el stack existe..."
if ! aws cloudformation describe-stacks --stack-name "$STACK_NAME" &>/dev/null; then
    echo "❌ El stack '$STACK_NAME' no existe o ya fue eliminado."
    exit 0
fi

echo "📋 Stack encontrado: $STACK_NAME"
echo ""
echo "⚠️  ADVERTENCIA: Esta acción eliminará:"
echo "   • API Gateway y todos los endpoints"
echo "   • 5 Funciones Lambda"
echo "   • Tabla DynamoDB con todos los productos"
echo "   • Bucket S3 del frontend"
echo "   • Distribución CloudFront"
echo "   • Todos los roles y políticas IAM"
echo ""
echo "💡 Esta operación es IRREVERSIBLE"
echo ""

read -p "¿Estás seguro de eliminar todos los recursos? (escribe 'si' para confirmar): " CONFIRM

if [ "$CONFIRM" = "si" ] || [ "$CONFIRM" = "SI" ] || [ "$CONFIRM" = "yes" ]; then
    echo ""
    echo "🗑️  Eliminando stack..."
    echo "-------------------------------------------"
    sam delete --stack-name "$STACK_NAME" --no-prompts

    echo ""
    echo "=========================================="
    echo "  ✅ ¡RECURSOS ELIMINADOS EXITOSAMENTE!"
    echo "=========================================="
    echo ""
    echo "💰 Tus recursos de AWS han sido eliminados."
    echo "   No se generarán más cargos."
    echo ""
    echo "📝 Próximos pasos:"
    echo "   • Puedes volver a desplegar cuando quieras con:"
    echo "     ./scripts/deploy-all.sh"
    echo "=========================================="
else
    echo ""
    echo "❌ Eliminación cancelada. No se eliminaron recursos."
    exit 1
fi
