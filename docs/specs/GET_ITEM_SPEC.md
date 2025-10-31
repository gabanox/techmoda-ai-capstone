# Lambda Function Specification: GetItem

## Purpose

Retrieve a single product by its productId from the TechModa fashion catalog using DynamoDB GetItem operation.

## API Endpoint

**Method**: `GET`

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
  "httpMethod": "GET",
  "path": "/products/123e4567-e89b-12d3-a456-426614174000",
  "pathParameters": {
    "id": "123e4567-e89b-12d3-a456-426614174000"
  },
  "headers": { ... },
  "body": null
}
```

**Access Path Parameter**: `event.pathParameters.id`

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

#### 404 Not Found

**HTTP Status Code**: 404

**Body**:
```json
{
  "error": "Not Found",
  "message": "Product not found"
}
```

#### 500 Internal Server Error

**HTTP Status Code**: 500

**Body**:
```json
{
  "error": "Internal server error",
  "message": "Failed to retrieve product"
}
```

## DynamoDB Operations

### Operation: GetItem

**Purpose**: Retrieve single item by primary key

**AWS SDK v3 Command**: `GetCommand`

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
  Item: {
    productId: "123e4567-e89b-12d3-a456-426614174000",
    name: "Classic Denim Jacket",
    // ... other attributes
  }
}
```

**If Not Found**:
```javascript
{
  // Item property is undefined
}
```

## Implementation Steps (Pseudocode)

```
1. Initialize DynamoDB client
   - Import DynamoDBClient from @aws-sdk/client-dynamodb
   - Import DynamoDBDocumentClient and GetCommand from @aws-sdk/lib-dynamodb
   - Create and wrap client

2. Define Lambda handler function
   - Async function: exports.handler = async (event)

3. Extract productId from path parameters
   - const productId = event.pathParameters.id

4. Prepare DynamoDB GetItem parameters
   - TableName: process.env.PRODUCTS_TABLE
   - Key: { productId }

5. Execute GetItem operation
   - Use try/catch for error handling
   - Send GetCommand to DynamoDB
   - Extract Item from response

6. Check if item exists
   - If Item is undefined/null: return 404 Not Found
   - If Item exists: return 200 OK with product

7. Handle success case (item found)
   - Return API Gateway response:
     * statusCode: 200
     * headers: Content-Type and CORS
     * body: JSON.stringify(Item)

8. Handle not found case
   - Return API Gateway response:
     * statusCode: 404
     * headers: Content-Type and CORS
     * body: JSON.stringify({ error: "Not Found", message: "Product not found" })

9. Handle error case
   - Log error to CloudWatch (console.error)
   - Return 500 response
```

## Testing Curl Command

### Get Existing Product

First, create a product and save its ID:

```bash
# Create product and save response
RESPONSE=$(curl -s -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Product", "price": 99.99}')

# Extract productId (requires jq)
PRODUCT_ID=$(echo $RESPONSE | jq -r '.productId')

# Get the product
curl -X GET $API_URL/products/$PRODUCT_ID
```

### Direct Test (with known ID)

```bash
curl -X GET https://{api-id}.execute-api.us-east-1.amazonaws.com/Prod/products/123e4567-e89b-12d3-a456-426614174000
```

### Test 404 Not Found

```bash
curl -X GET $API_URL/products/nonexistent-id-12345
```

**Expected**: 404 Not Found

### Expected Success Response

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

### Verify in CloudWatch Logs

```bash
aws logs tail /aws/lambda/techmoda-capstone-GetItem --follow
```

## Claude Code Prompt

```
I need to implement a Lambda function in Node.js 18.x that retrieves a single product by ID from DynamoDB.

Requirements:
- Function name: GetItem
- Runtime: Node.js 18.x
- Trigger: API Gateway (GET /products/{id})
- Path parameter: id (productId)
- Database: DynamoDB table (name from environment variable PRODUCTS_TABLE)
- Operation: GetItem by productId
- Response: Product object with HTTP 200 if found
- Response: Error message with HTTP 404 if not found
- Error handling: 500 for DynamoDB errors
- CORS: Include Access-Control-Allow-Origin: * header

Please generate:
1. Complete index.js with exports.handler
2. Extract productId from event.pathParameters.id
3. AWS SDK v3 DynamoDB GetItem
4. Check if item exists
5. Return 404 if not found, 200 if found
6. Error handling with try/catch
7. API Gateway response format
```

## Implementation Notes

### Extracting Path Parameters

API Gateway passes path parameters in `event.pathParameters`:

```javascript
const productId = event.pathParameters.id;
```

**Safety Check** (optional):
```javascript
if (!event.pathParameters || !event.pathParameters.id) {
  return {
    statusCode: 400,
    headers: {...},
    body: JSON.stringify({
      error: 'Bad Request',
      message: 'Missing product ID'
    })
  };
}
```

### Checking Item Existence

DynamoDB GetItem returns `undefined` for Item if not found:

```javascript
const result = await docClient.send(new GetCommand({...}));

if (!result.Item) {
  // Item not found, return 404
  return {
    statusCode: 404,
    headers: {...},
    body: JSON.stringify({
      error: 'Not Found',
      message: 'Product not found'
    })
  };
}

// Item found, return 200
return {
  statusCode: 200,
  headers: {...},
  body: JSON.stringify(result.Item)
};
```

### Performance

GetItem is the fastest DynamoDB operation:
- Direct key lookup
- Single-digit millisecond latency
- Strongly consistent by default

### CORS Headers

Include in all responses (200, 404, 500):

```javascript
const headers = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*'
};
```

## Common Errors and Solutions

### Error: "Cannot read property 'id' of undefined"

**Cause**: Path parameter not passed correctly

**Solution**: Verify API Gateway route includes `{id}` parameter in template.yaml:
```yaml
Path: /products/{id}
Method: get
```

### Error: "Product not found" (but product exists)

**Cause**: Wrong productId or case sensitivity issue

**Solution**:
- Copy exact productId from CreateItem response
- DynamoDB keys are case-sensitive
- Verify table has item with `aws dynamodb get-item`

### Error: "ValidationException: One or more parameter values were invalid"

**Cause**: Missing or invalid Key in GetItem parameters

**Solution**: Ensure Key object matches table schema:
```javascript
Key: {
  productId: "the-actual-uuid"
}
```

## Validation Criteria

Your GetItem function is correctly implemented when:

✅ GET /products/{id} with valid ID returns 200 OK
✅ Response contains complete product object
✅ GET /products/{invalid-id} returns 404 Not Found
✅ 404 response includes error message
✅ CORS headers present in all responses
✅ CloudWatch Logs show GetItem operation
✅ X-Ray trace displays DynamoDB GetItem segment (fast, <50ms)
✅ Function works for products created via CreateItem

## Next Steps

After implementing GetItem:

1. Deploy with `sam build && sam deploy`
2. Create a product with POST /products
3. Copy the returned productId
4. Test GET /products/{id} with that ID
5. Verify 200 response with product details
6. Test with non-existent ID to verify 404
7. Check CloudWatch Logs
8. Proceed to implement UpdateItem function
