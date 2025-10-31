# Lambda Function Specification: DeleteItem

## Purpose

Remove a product from the TechModa fashion catalog using DynamoDB DeleteItem operation.

## API Endpoint

**Method**: `DELETE`

**Path**: `/products/{id}`

**Trigger**: API Gateway REST API event with path parameter

## Input Schema

### Path Parameters

**Required**: `id` (productId)

**Example**: `/products/123e4567-e89b-12d3-a456-426614174000`

### Query Parameters
None

### Request Headers
None required

### Request Body
None

### API Gateway Event Structure
```javascript
{
  "httpMethod": "DELETE",
  "path": "/products/123e4567-e89b-12d3-a456-426614174000",
  "pathParameters": {
    "id": "123e4567-e89b-12d3-a456-426614174000"
  },
  "headers": { ... },
  "body": null
}
```

## Output Schema

### Success Response (200 OK)

**HTTP Status Code**: 200

**Headers**:
```javascript
{
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*"
}
```

**Body**:
```json
{
  "message": "Product deleted successfully",
  "productId": "123e4567-e89b-12d3-a456-426614174000"
}
```

### Error Responses

#### 404 Not Found (Optional)

**HTTP Status Code**: 404

**Body**:
```json
{
  "error": "Not Found",
  "message": "Product not found"
}
```

**Note**: This is only returned if you implement an existence check. DynamoDB DeleteItem is idempotent and succeeds even if the item doesn't exist.

#### 500 Internal Server Error

**HTTP Status Code**: 500

**Body**:
```json
{
  "error": "Internal server error",
  "message": "Failed to delete product"
}
```

## DynamoDB Operations

### Operation: DeleteItem

**Purpose**: Remove item from table by primary key

**AWS SDK v3 Command**: `DeleteCommand`

**Parameters**:
```javascript
{
  TableName: process.env.PRODUCTS_TABLE,
  Key: {
    productId: "123e4567-e89b-12d3-a456-426614174000"
  }
}
```

**Response**:
```javascript
{
  // Empty response on success
  // DynamoDB DeleteItem does not return the deleted item by default
}
```

**Idempotent Behavior**: DeleteItem succeeds even if the item doesn't exist. This is by design for idempotent operations.

### Optional: ReturnValues for Verification

If you want to verify the item existed before deletion:

```javascript
{
  TableName: process.env.PRODUCTS_TABLE,
  Key: {
    productId: "123e4567-e89b-12d3-a456-426614174000"
  },
  ReturnValues: "ALL_OLD"
}
```

**Response if item existed**:
```javascript
{
  Attributes: {
    productId: "123e4567-e89b-12d3-a456-426614174000",
    name: "Classic Denim Jacket",
    // ... all attributes before deletion
  }
}
```

**Response if item didn't exist**:
```javascript
{
  // Attributes property is undefined
}
```

## Implementation Steps (Pseudocode)

### Basic Implementation (No Existence Check)

```
1. Initialize DynamoDB client
   - Import DynamoDBClient from @aws-sdk/client-dynamodb
   - Import DynamoDBDocumentClient and DeleteCommand from @aws-sdk/lib-dynamodb
   - Create and wrap client

2. Define Lambda handler function
   - Async function: exports.handler = async (event)

3. Extract productId from path parameters
   - const productId = event.pathParameters.id

4. Prepare DynamoDB DeleteItem parameters
   - TableName: process.env.PRODUCTS_TABLE
   - Key: { productId }

5. Execute DeleteItem operation
   - Use try/catch for error handling
   - Send DeleteCommand to DynamoDB

6. Handle success case
   - Return API Gateway response:
     * statusCode: 200
     * headers: Content-Type and CORS
     * body: JSON.stringify({ message: "Product deleted successfully", productId })

7. Handle error case
   - Log error to CloudWatch (console.error)
   - Return 500 response
```

### Advanced Implementation (With Existence Check)

```
1-3. Same as basic implementation

4. Check if product exists
   - Execute GetItem with productId
   - If Item is undefined, return 404 Not Found

5. Execute DeleteItem operation
   - Use try/catch for error handling
   - Send DeleteCommand to DynamoDB

6-7. Same as basic implementation
```

## Testing Curl Command

### Delete Existing Product

First, create a product:

```bash
# Create product
RESPONSE=$(curl -s -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Product To Delete", "price": 99.99}')

# Extract productId
PRODUCT_ID=$(echo $RESPONSE | jq -r '.productId')
echo "Created product: $PRODUCT_ID"

# Delete the product
curl -X DELETE $API_URL/products/$PRODUCT_ID
```

### Direct Test (with known ID)

```bash
curl -X DELETE https://{api-id}.execute-api.us-east-1.amazonaws.com/Prod/products/123e4567-e89b-12d3-a456-426614174000
```

### Verify Deletion

```bash
# Try to get the deleted product (should return 404)
curl -X GET $API_URL/products/$PRODUCT_ID
```

### Test Idempotency (Delete Twice)

```bash
# Delete once
curl -X DELETE $API_URL/products/$PRODUCT_ID

# Delete again (should still return 200 if no existence check)
curl -X DELETE $API_URL/products/$PRODUCT_ID
```

### Complete Test Workflow

```bash
#!/bin/bash

# 1. Create product
echo "1. Creating product..."
RESPONSE=$(curl -s -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Temporary Product", "price": 49.99}')
PRODUCT_ID=$(echo $RESPONSE | jq -r '.productId')
echo "Created: $PRODUCT_ID"

# 2. Verify product exists
echo "2. Verifying product exists..."
curl -s -X GET $API_URL/products/$PRODUCT_ID | jq .

# 3. Delete product
echo "3. Deleting product..."
curl -s -X DELETE $API_URL/products/$PRODUCT_ID | jq .

# 4. Verify deletion (should return 404)
echo "4. Verifying deletion..."
curl -s -X GET $API_URL/products/$PRODUCT_ID | jq .

# 5. List products (deleted product should not appear)
echo "5. Listing products..."
curl -s -X GET $API_URL/products | jq .
```

### Expected Success Response

```json
{
  "message": "Product deleted successfully",
  "productId": "123e4567-e89b-12d3-a456-426614174000"
}
```

## Claude Code Prompt

```
I need to implement a Lambda function in Node.js 18.x that deletes a product from DynamoDB.

Requirements:
- Function name: DeleteItem
- Runtime: Node.js 18.x
- Trigger: API Gateway (DELETE /products/{id})
- Path parameter: id (productId)
- Database: DynamoDB table (name from environment variable PRODUCTS_TABLE)
- Operation: DeleteItem by productId
- Response: Success message with HTTP 200
- Note: DynamoDB DeleteItem is idempotent (succeeds even if item doesn't exist)
- Optional: Check existence first to return accurate 404
- Error handling: 500 for DynamoDB errors
- CORS: Include Access-Control-Allow-Origin: * header

Please generate:
1. Complete index.js with exports.handler
2. Extract productId from path parameters
3. AWS SDK v3 DynamoDB DeleteItem
4. Success response with confirmation message
5. Error handling with try/catch
6. API Gateway response format
```

## Implementation Notes

### Idempotent Operations

DynamoDB DeleteItem always succeeds, even if the item doesn't exist. This is intentional:

**Benefit**: Simplifies error handling and supports retries
**Trade-off**: Can't distinguish between "deleted existing item" and "item already gone"

**Decision**: For this capstone, simple implementation without existence check is acceptable.

### Optional Existence Check

If you want to return 404 for non-existent products:

```javascript
// Check if product exists
const getResult = await docClient.send(new GetCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: { productId }
}));

if (!getResult.Item) {
  return {
    statusCode: 404,
    headers: {...},
    body: JSON.stringify({
      error: 'Not Found',
      message: 'Product not found'
    })
  };
}

// Proceed with deletion
await docClient.send(new DeleteCommand({...}));
```

**Trade-off**: Adds latency (extra DynamoDB call) but provides better error reporting.

### ReturnValues

Use `ReturnValues: "ALL_OLD"` to get deleted item data:

```javascript
const result = await docClient.send(new DeleteCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: { productId },
  ReturnValues: 'ALL_OLD'
}));

if (!result.Attributes) {
  // Item didn't exist
  return { statusCode: 404, ... };
}

// Item was deleted, return it
return {
  statusCode: 200,
  headers: {...},
  body: JSON.stringify({
    message: 'Product deleted successfully',
    deletedProduct: result.Attributes
  })
};
```

### CORS Headers

Include in all responses:

```javascript
const headers = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*'
};
```

## Common Errors and Solutions

### Error: "Cannot read property 'id' of undefined"

**Cause**: Path parameter not passed correctly

**Solution**: Verify API Gateway route in template.yaml:
```yaml
Path: /products/{id}
Method: delete
```

### Error: "ValidationException: One or more parameter values were invalid"

**Cause**: Missing or invalid Key

**Solution**: Ensure Key matches table schema:
```javascript
Key: {
  productId: "the-uuid"
}
```

### No Error, But Item Still Exists

**Cause**: Wrong productId or DynamoDB operation failed silently

**Solution**:
- Verify productId matches exactly
- Check CloudWatch Logs for errors
- Use AWS CLI to verify deletion:
```bash
aws dynamodb get-item \
  --table-name techmoda-capstone-Products \
  --key '{"productId": {"S": "the-uuid"}}'
```

## Validation Criteria

Your DeleteItem function is correctly implemented when:

✅ DELETE /products/{id} returns 200 OK
✅ Response includes success message and productId
✅ Deleted product no longer appears in GET /products
✅ GET /products/{id} for deleted product returns 404
✅ CORS headers present in response
✅ CloudWatch Logs show DeleteItem operation
✅ X-Ray trace displays DynamoDB DeleteItem segment
✅ Deleting non-existent ID still returns 200 (or 404 if existence check implemented)

### Additional Verification

**Verify in DynamoDB**:
```bash
aws dynamodb scan \
  --table-name techmoda-capstone-Products \
  --filter-expression "productId = :id" \
  --expression-attribute-values '{":id": {"S": "the-uuid"}}'
```

**Expected**: Empty Items array

## Next Steps

After implementing DeleteItem:

1. Deploy with `sam build && sam deploy`
2. Create a test product with POST /products
3. Save the productId
4. Delete with DELETE /products/{id}
5. Verify 200 response
6. Try GET /products/{id} (should return 404)
7. Try GET /products (deleted product shouldn't appear)
8. Test deleting non-existent ID
9. Check CloudWatch Logs
10. Celebrate completing all 5 CRUD operations!

## Congratulations!

With DeleteItem implemented, you now have a complete serverless REST API with:

✅ List all products (GET /products)
✅ Create product (POST /products)
✅ Get product by ID (GET /products/{id})
✅ Update product (PUT /products/{id})
✅ Delete product (DELETE /products/{id})

**Next**: Test end-to-end workflow, document in README, and prepare for submission!
