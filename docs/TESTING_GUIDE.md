# API Testing Guide

## Overview

This guide provides complete instructions for manually testing your TechModa Product Catalog API using curl commands. You'll learn how to retrieve your API Gateway URL, execute tests for all 5 CRUD operations, and interpret responses.

## Prerequisites

- Deployed SAM stack (run `sam build && sam deploy --guided` first)
- curl installed (pre-installed on macOS/Linux, available via Git Bash on Windows)
- Terminal or command prompt access

## Step 1: Retrieve Your API Gateway URL

After deploying your SAM application, you need the API Gateway endpoint URL.

### Method 1: From Deployment Output

When `sam deploy` completes, look for the Outputs section:

```
CloudFormation outputs from deployed stack
-------------------------------------------------
Outputs
-------------------------------------------------
Key                 TechModaApi
Description         API Gateway endpoint URL
Value               https://abc123xyz.execute-api.us-east-1.amazonaws.com/Prod
-------------------------------------------------
```

Copy the URL from the `Value` field.

### Method 2: AWS CLI Command

```bash
aws cloudformation describe-stacks \
  --stack-name techmoda-capstone \
  --query "Stacks[0].Outputs[?OutputKey=='TechModaApi'].OutputValue" \
  --output text
```

### Method 3: AWS Console

1. Go to AWS CloudFormation console
2. Select your stack (e.g., `techmoda-capstone`)
3. Click the "Outputs" tab
4. Copy the value for `TechModaApi`

### Set Environment Variable (Recommended)

For easier testing, save your API URL as an environment variable:

**macOS/Linux**:
```bash
export API_URL="https://abc123xyz.execute-api.us-east-1.amazonaws.com/Prod"
```

**Windows (PowerShell)**:
```powershell
$env:API_URL = "https://abc123xyz.execute-api.us-east-1.amazonaws.com/Prod"
```

**Windows (CMD)**:
```cmd
set API_URL=https://abc123xyz.execute-api.us-east-1.amazonaws.com/Prod
```

Now you can use `$API_URL` (or `%API_URL%` on Windows CMD) in curl commands.

## Step 2: Test Workflow

Follow this recommended testing sequence to verify all CRUD operations:

1. **Create Product** - Add a product to the database
2. **List Products** - Verify the product appears in the list
3. **Get Product** - Retrieve the specific product by ID
4. **Update Product** - Modify product details
5. **Delete Product** - Remove the product from the catalog

## Test 1: Create Product (POST)

### Purpose
Create a new fashion product in the catalog.

### Curl Command

```bash
curl -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Classic Denim Jacket",
    "description": "Timeless denim jacket for all seasons",
    "price": 79.99,
    "category": "Jackets",
    "imageUrl": "https://example.com/denim-jacket.jpg"
  }'
```

### Expected Success Response (201 Created)

```json
{
  "productId": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Classic Denim Jacket",
  "description": "Timeless denim jacket for all seasons",
  "price": 79.99,
  "category": "Jackets",
  "imageUrl": "https://example.com/denim-jacket.jpg",
  "createdAt": "2025-10-30T12:00:00.000Z",
  "updatedAt": "2025-10-30T12:00:00.000Z"
}
```

**Important**: Save the `productId` from the response - you'll need it for Get, Update, and Delete tests.

### Example: Save productId

**macOS/Linux/PowerShell**:
```bash
# Save entire response to file
curl -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Classic Denim Jacket", "price": 79.99}' \
  > product.json

# Extract productId (requires jq)
PRODUCT_ID=$(jq -r '.productId' product.json)
echo $PRODUCT_ID
```

### Error Responses

**400 Bad Request** (missing required fields):
```json
{
  "error": "Bad Request",
  "message": "Missing required field: name"
}
```

**500 Internal Server Error** (DynamoDB permissions or other issues):
```json
{
  "error": "Internal server error",
  "message": "Failed to create product"
}
```

### Troubleshooting

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| 400 Bad Request | Missing `name` or `price` | Add required fields to JSON body |
| 403 Forbidden | IAM permissions issue | Check SAM template DynamoDB policies |
| 500 Internal Server Error | Lambda execution error | Check CloudWatch Logs |
| Connection refused | Wrong API URL | Verify API Gateway URL |

## Test 2: List Products (GET)

### Purpose
Retrieve all products in the catalog.

### Curl Command

```bash
curl -X GET $API_URL/products
```

### Expected Success Response (200 OK)

```json
{
  "products": [
    {
      "productId": "123e4567-e89b-12d3-a456-426614174000",
      "name": "Classic Denim Jacket",
      "description": "Timeless denim jacket for all seasons",
      "price": 79.99,
      "category": "Jackets",
      "imageUrl": "https://example.com/denim-jacket.jpg",
      "createdAt": "2025-10-30T12:00:00.000Z",
      "updatedAt": "2025-10-30T12:00:00.000Z"
    }
  ]
}
```

If the database is empty:
```json
{
  "products": []
}
```

### Error Responses

**500 Internal Server Error**:
```json
{
  "error": "Internal server error",
  "message": "Failed to retrieve products"
}
```

### Verification Steps

1. Confirm the product you created appears in the list
2. Verify all attributes are present (productId, name, price, etc.)
3. Check that timestamps are in ISO 8601 format

## Test 3: Get Product by ID (GET)

### Purpose
Retrieve a single product using its productId.

### Curl Command

Replace `{PRODUCT_ID}` with the actual UUID from the Create Product response.

```bash
curl -X GET $API_URL/products/{PRODUCT_ID}
```

**Example with saved variable**:
```bash
curl -X GET $API_URL/products/$PRODUCT_ID
```

**Example with actual UUID**:
```bash
curl -X GET $API_URL/products/123e4567-e89b-12d3-a456-426614174000
```

### Expected Success Response (200 OK)

```json
{
  "productId": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Classic Denim Jacket",
  "description": "Timeless denim jacket for all seasons",
  "price": 79.99,
  "category": "Jackets",
  "imageUrl": "https://example.com/denim-jacket.jpg",
  "createdAt": "2025-10-30T12:00:00.000Z",
  "updatedAt": "2025-10-30T12:00:00.000Z"
}
```

### Error Responses

**404 Not Found** (product doesn't exist):
```json
{
  "error": "Not Found",
  "message": "Product not found"
}
```

**500 Internal Server Error**:
```json
{
  "error": "Internal server error",
  "message": "Failed to retrieve product"
}
```

### Troubleshooting

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| 404 Not Found | Wrong productId or product deleted | Verify productId from List Products |
| 500 Internal Server Error | Lambda error | Check CloudWatch Logs |

## Test 4: Update Product (PUT)

### Purpose
Update existing product details (partial update).

### Curl Command

Replace `{PRODUCT_ID}` with the actual UUID.

```bash
curl -X PUT $API_URL/products/{PRODUCT_ID} \
  -H "Content-Type: application/json" \
  -d '{
    "price": 69.99,
    "description": "Updated: Timeless denim jacket now on sale!"
  }'
```

**Example with saved variable**:
```bash
curl -X PUT $API_URL/products/$PRODUCT_ID \
  -H "Content-Type: application/json" \
  -d '{
    "price": 69.99,
    "description": "Updated: Timeless denim jacket now on sale!"
  }'
```

### Expected Success Response (200 OK)

```json
{
  "productId": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Classic Denim Jacket",
  "description": "Updated: Timeless denim jacket now on sale!",
  "price": 69.99,
  "category": "Jackets",
  "imageUrl": "https://example.com/denim-jacket.jpg",
  "createdAt": "2025-10-30T12:00:00.000Z",
  "updatedAt": "2025-10-30T14:30:00.000Z"
}
```

**Note**: `updatedAt` timestamp should change, `createdAt` should remain the same.

### Error Responses

**404 Not Found**:
```json
{
  "error": "Not Found",
  "message": "Product not found"
}
```

**400 Bad Request** (invalid data):
```json
{
  "error": "Bad Request",
  "message": "Invalid update data"
}
```

**500 Internal Server Error**:
```json
{
  "error": "Internal server error",
  "message": "Failed to update product"
}
```

### Verification Steps

1. Confirm updated fields changed (price, description)
2. Verify unchanged fields remain the same (name, category)
3. Check that `updatedAt` timestamp is newer than `createdAt`
4. Run Get Product again to verify changes persisted

## Test 5: Delete Product (DELETE)

### Purpose
Remove a product from the catalog.

### Curl Command

Replace `{PRODUCT_ID}` with the actual UUID.

```bash
curl -X DELETE $API_URL/products/{PRODUCT_ID}
```

**Example with saved variable**:
```bash
curl -X DELETE $API_URL/products/$PRODUCT_ID
```

### Expected Success Response (200 OK)

```json
{
  "message": "Product deleted successfully",
  "productId": "123e4567-e89b-12d3-a456-426614174000"
}
```

### Error Responses

**404 Not Found** (if existence check is implemented):
```json
{
  "error": "Not Found",
  "message": "Product not found"
}
```

**500 Internal Server Error**:
```json
{
  "error": "Internal server error",
  "message": "Failed to delete product"
}
```

### Verification Steps

1. Run List Products again - deleted product should not appear
2. Try Get Product with same ID - should return 404 Not Found
3. Try Delete again - should still return success (DynamoDB DeleteItem is idempotent)

## Complete Test Script

Here's a complete bash script to test all endpoints in sequence:

```bash
#!/bin/bash

# Configuration
API_URL="https://your-api-id.execute-api.us-east-1.amazonaws.com/Prod"

echo "=== TechModa API Test Suite ==="
echo ""

# Test 1: Create Product
echo "1. Creating product..."
CREATE_RESPONSE=$(curl -s -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Classic Denim Jacket",
    "description": "Timeless denim jacket for all seasons",
    "price": 79.99,
    "category": "Jackets",
    "imageUrl": "https://example.com/jacket.jpg"
  }')

echo $CREATE_RESPONSE | jq .
PRODUCT_ID=$(echo $CREATE_RESPONSE | jq -r '.productId')
echo "Product ID: $PRODUCT_ID"
echo ""

# Test 2: List Products
echo "2. Listing all products..."
curl -s -X GET $API_URL/products | jq .
echo ""

# Test 3: Get Product
echo "3. Getting product by ID..."
curl -s -X GET $API_URL/products/$PRODUCT_ID | jq .
echo ""

# Test 4: Update Product
echo "4. Updating product..."
curl -s -X PUT $API_URL/products/$PRODUCT_ID \
  -H "Content-Type: application/json" \
  -d '{
    "price": 69.99,
    "description": "Updated: Now on sale!"
  }' | jq .
echo ""

# Test 5: Verify Update
echo "5. Verifying update..."
curl -s -X GET $API_URL/products/$PRODUCT_ID | jq .
echo ""

# Test 6: Delete Product
echo "6. Deleting product..."
curl -s -X DELETE $API_URL/products/$PRODUCT_ID | jq .
echo ""

# Test 7: Verify Deletion
echo "7. Verifying deletion (should return 404)..."
curl -s -X GET $API_URL/products/$PRODUCT_ID | jq .
echo ""

echo "=== Test Suite Complete ==="
```

**Usage**:
1. Save as `test-api.sh`
2. Update `API_URL` with your actual endpoint
3. Make executable: `chmod +x test-api.sh`
4. Run: `./test-api.sh`

**Note**: Requires `jq` for JSON formatting. Install with:
- macOS: `brew install jq`
- Ubuntu/Debian: `sudo apt-get install jq`
- Windows: Download from https://stedolan.github.io/jq/

## Advanced Testing

### Pretty Print JSON Responses

Add `| jq .` to any curl command:

```bash
curl -X GET $API_URL/products | jq .
```

### Include HTTP Headers in Response

Add `-i` flag to see status codes and headers:

```bash
curl -i -X GET $API_URL/products
```

### Verbose Output for Debugging

Add `-v` flag to see full request/response details:

```bash
curl -v -X GET $API_URL/products
```

### Test Error Scenarios

**Missing required field**:
```bash
curl -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{"description": "No name or price"}'
```

**Invalid product ID**:
```bash
curl -X GET $API_URL/products/invalid-id
```

**Malformed JSON**:
```bash
curl -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{invalid json}'
```

## CloudWatch Logs Analysis

After running tests, check Lambda execution logs for debugging:

### View Logs (AWS CLI)

**List recent log streams**:
```bash
aws logs tail /aws/lambda/techmoda-capstone-CreateItem --follow
```

**Get last 50 log events**:
```bash
aws logs tail /aws/lambda/techmoda-capstone-CreateItem --since 5m
```

### View Logs (AWS Console)

1. Go to CloudWatch → Log groups
2. Select `/aws/lambda/{StackName}-{FunctionName}`
3. Click latest log stream
4. Look for:
   - START/END lines (execution boundaries)
   - Console.log() output
   - ERROR messages with stack traces
   - REPORT line (duration, memory usage)

### Example Log Entry

```
START RequestId: abc-123-def Version: $LATEST
2025-10-30T12:00:00.000Z  abc-123-def  INFO  Received event: {"body": "{...}"}
2025-10-30T12:00:00.100Z  abc-123-def  INFO  Created product: 123e4567...
END RequestId: abc-123-def
REPORT RequestId: abc-123-def  Duration: 150.00 ms  Billed Duration: 150 ms  Memory Size: 1024 MB  Max Memory Used: 85 MB
```

## X-Ray Traces Analysis

### View Traces (AWS Console)

1. Go to X-Ray → Traces
2. Filter by time range (last 5 minutes)
3. Click on a trace to see details:
   - API Gateway segment (request routing)
   - Lambda segment (function execution)
   - DynamoDB segment (database operations)
4. Check Service Map for visual overview

### What to Look For

- **Cold starts**: First invocation after deployment (slower)
- **DynamoDB latency**: Should be <50ms for GetItem
- **Total duration**: Compare to Lambda execution time
- **Errors**: Red segments indicate failures

## Common Issues and Solutions

### Issue: "curl: command not found"

**Solution**: Install curl
- macOS: Pre-installed
- Windows: Use Git Bash or install from https://curl.se/
- Linux: `sudo apt-get install curl` or `sudo yum install curl`

### Issue: "Connection refused" or "Could not resolve host"

**Solution**: Verify API Gateway URL
- Check CloudFormation Outputs
- Ensure URL includes `https://` and `/Prod` stage
- No trailing slash in base URL

### Issue: 403 Forbidden

**Solution**: IAM permission problem
- Check SAM template DynamoDB policies
- Verify Lambda execution role has necessary permissions
- Redeploy with `sam build && sam deploy`

### Issue: 500 Internal Server Error

**Solution**: Lambda execution error
1. Check CloudWatch Logs for the specific function
2. Look for JavaScript errors (TypeError, ReferenceError)
3. Verify environment variable `PRODUCTS_TABLE` is set
4. Check DynamoDB table exists and is accessible

### Issue: 404 Not Found (wrong reason)

**Solution**: API Gateway routing issue
- Verify endpoint path matches template.yaml
- Check HTTP method (GET vs POST vs PUT vs DELETE)
- Ensure `/products` and `/products/{id}` routes exist

### Issue: Empty response or timeout

**Solution**: Lambda timeout or initialization error
- Increase timeout in template.yaml (default 30s)
- Check Lambda function has AWS SDK imports
- Verify Node.js 18.x runtime compatibility

## Best Practices

1. **Test incrementally**: Don't wait to test all functions at once
2. **Save productIds**: Keep track of created products for testing
3. **Check logs immediately**: If a test fails, check CloudWatch right away
4. **Use environment variables**: Store API_URL for easier testing
5. **Test error cases**: Verify error handling works correctly
6. **Clean up test data**: Delete products after testing to avoid clutter

## Next Steps

- Review [Debugging Guide](prompts/05_DEBUGGING.md) if tests fail
- Check [CloudWatch Logs](prompts/05_DEBUGGING.md#prompt-51-analyze-cloudwatch-logs) for errors
- Explore [X-Ray Traces](prompts/06_OPERATIONS.md#prompt-61-view-x-ray-traces) for performance insights
- See [Cost Estimation](COST_AND_CLEANUP.md) for pricing details
