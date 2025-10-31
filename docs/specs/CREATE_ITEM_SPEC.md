# Lambda Function Specification: CreateItem

## Purpose

Add a new product to the TechModa fashion catalog by performing a DynamoDB PutItem operation with auto-generated UUID and timestamps.

## API Endpoint

**Method**: `POST`

**Path**: `/products`

**Trigger**: API Gateway REST API event with JSON body

## Input Schema

### Path Parameters
None

### Query Parameters
None

### Request Headers
```
Content-Type: application/json
```

### Request Body

**Required Fields**: `name`, `price`

**Optional Fields**: `description`, `category`, `imageUrl`

**Example**:
```json
{
  "name": "Classic Denim Jacket",
  "description": "Timeless denim jacket for all seasons",
  "price": 79.99,
  "category": "Jackets",
  "imageUrl": "https://example.com/denim-jacket.jpg"
}
```

**Minimal Example**:
```json
{
  "name": "Summer Dress",
  "price": 49.99
}
```

### API Gateway Event Structure
```javascript
{
  "httpMethod": "POST",
  "path": "/products",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "{\"name\":\"Classic Denim Jacket\",\"price\":79.99}"
}
```

**Important**: `event.body` is a JSON string, not an object. You must parse it with `JSON.parse(event.body)`.

## Output Schema

### Success Response (201 Created)

**HTTP Status Code**: 201

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

#### 400 Bad Request (Missing Required Fields)

**HTTP Status Code**: 400

**Body**:
```json
{
  "error": "Bad Request",
  "message": "Missing required field: name"
}
```

Or:
```json
{
  "error": "Bad Request",
  "message": "Missing required field: price"
}
```

#### 400 Bad Request (Invalid JSON)

**Body**:
```json
{
  "error": "Bad Request",
  "message": "Invalid JSON in request body"
}
```

#### 500 Internal Server Error

**HTTP Status Code**: 500

**Body**:
```json
{
  "error": "Internal server error",
  "message": "Failed to create product"
}
```

## DynamoDB Operations

### Operation: PutItem

**Purpose**: Create new item in the TechModa-Products table

**AWS SDK v3 Command**: `PutCommand`

**Parameters**:
```javascript
{
  TableName: process.env.PRODUCTS_TABLE,
  Item: {
    productId: "123e4567-e89b-12d3-a456-426614174000",
    name: "Classic Denim Jacket",
    description: "Timeless denim jacket for all seasons",
    price: 79.99,
    category: "Jackets",
    imageUrl: "https://example.com/jacket.jpg",
    createdAt: "2025-10-30T12:00:00.000Z",
    updatedAt: "2025-10-30T12:00:00.000Z"
  }
}
```

**Response**:
PutItem returns an empty response on success. The function should return the created item.

## Implementation Steps (Pseudocode)

```
1. Initialize DynamoDB client
   - Import DynamoDBClient from @aws-sdk/client-dynamodb
   - Import DynamoDBDocumentClient and PutCommand from @aws-sdk/lib-dynamodb
   - Create and wrap client

2. Define Lambda handler function
   - Async function: exports.handler = async (event)

3. Parse request body
   - Use try/catch for JSON.parse(event.body)
   - If parse fails, return 400 Bad Request

4. Validate required fields
   - Check if body.name exists
   - Check if body.price exists
   - If missing, return 400 with specific error message

5. Generate product object
   - productId: crypto.randomUUID()
   - name: body.name
   - description: body.description (optional)
   - price: body.price
   - category: body.category (optional)
   - imageUrl: body.imageUrl (optional)
   - createdAt: new Date().toISOString()
   - updatedAt: new Date().toISOString()

6. Execute PutItem operation
   - Use try/catch for error handling
   - Send PutCommand to DynamoDB
   - Parameters: TableName and Item

7. Handle success case
   - Return API Gateway response:
     * statusCode: 201
     * headers: Content-Type and CORS
     * body: JSON.stringify(product)

8. Handle error cases
   - Log error to CloudWatch (console.error)
   - Return 500 response with error details
```

## Testing Curl Command

### Create Product with All Fields

```bash
curl -X POST https://{api-id}.execute-api.us-east-1.amazonaws.com/Prod/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Classic Denim Jacket",
    "description": "Timeless denim jacket for all seasons",
    "price": 79.99,
    "category": "Jackets",
    "imageUrl": "https://example.com/denim-jacket.jpg"
  }'
```

### Create Product with Minimal Fields

```bash
curl -X POST https://{api-id}.execute-api.us-east-1.amazonaws.com/Prod/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Summer Dress",
    "price": 49.99
  }'
```

### Test Validation (Missing Name)

```bash
curl -X POST https://{api-id}.execute-api.us-east-1.amazonaws.com/Prod/products \
  -H "Content-Type: application/json" \
  -d '{
    "price": 49.99
  }'
```

**Expected**: 400 Bad Request with "Missing required field: name"

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

**Important**: Save the `productId` from the response for use in Get, Update, and Delete tests.

### Verify in DynamoDB

```bash
aws dynamodb scan \
  --table-name techmoda-capstone-Products \
  --query "Items[*].[productId.S, name.S, price.N]"
```

## Claude Code Prompt

```
I need to implement a Lambda function in Node.js 18.x that creates a new product in DynamoDB.

Requirements:
- Function name: CreateItem
- Runtime: Node.js 18.x
- Trigger: API Gateway (POST /products with JSON body)
- Database: DynamoDB table (name from environment variable PRODUCTS_TABLE)
- Input validation: name and price are required fields
- Generate UUID for productId using crypto.randomUUID()
- Add timestamps: createdAt and updatedAt (ISO 8601 format)
- Response: Created product object with HTTP 201
- Error handling: 400 for validation errors, 500 for DynamoDB errors
- CORS: Include Access-Control-Allow-Origin: * header

Input JSON body:
{
  "name": "Product name",
  "description": "Description",
  "price": 99.99,
  "category": "Category",
  "imageUrl": "https://..."
}

Please generate:
1. Complete index.js with exports.handler
2. AWS SDK v3 for DynamoDB
3. Input validation logic
4. UUID generation
5. Timestamp generation
6. DynamoDB PutItem operation
7. Proper error responses (400/500)
8. API Gateway response format
```

## Implementation Notes

### UUID Generation

Use Node.js built-in crypto module:

```javascript
const crypto = require('crypto');

const productId = crypto.randomUUID();
// Example: "123e4567-e89b-12d3-a456-426614174000"
```

**Alternative**: Import `uuid` package, but crypto is built-in and sufficient.

### ISO 8601 Timestamps

Use JavaScript Date object:

```javascript
const timestamp = new Date().toISOString();
// Example: "2025-10-30T12:00:00.000Z"
```

### Input Validation

Check required fields before DynamoDB operation:

```javascript
if (!body.name) {
  return {
    statusCode: 400,
    headers: {...},
    body: JSON.stringify({
      error: 'Bad Request',
      message: 'Missing required field: name'
    })
  };
}

if (!body.price) {
  return {
    statusCode: 400,
    headers: {...},
    body: JSON.stringify({
      error: 'Bad Request',
      message: 'Missing required field: price'
    })
  };
}
```

### JSON Parsing Safety

Wrap JSON.parse in try/catch:

```javascript
let body;
try {
  body = JSON.parse(event.body);
} catch (error) {
  return {
    statusCode: 400,
    headers: {...},
    body: JSON.stringify({
      error: 'Bad Request',
      message: 'Invalid JSON in request body'
    })
  };
}
```

### 201 Created Status Code

Use 201 (not 200) to indicate resource creation:

```javascript
return {
  statusCode: 201,
  headers: {...},
  body: JSON.stringify(product)
};
```

## Common Errors and Solutions

### Error: "Missing required field: name"

**Cause**: Request body doesn't include `name` field

**Solution**: Ensure curl command includes `"name": "..."` in JSON body

### Error: "SyntaxError: Unexpected token..."

**Cause**: Malformed JSON in request body

**Solution**: Validate JSON syntax. Use online JSON validator or `jq` to check:
```bash
echo '{"name":"Test","price":99.99}' | jq .
```

### Error: "crypto.randomUUID is not a function"

**Cause**: Using Node.js version < 14.17

**Solution**: Verify Lambda runtime is Node.js 18.x in template.yaml:
```yaml
Runtime: nodejs18.x
```

### Error: "ConditionalCheckFailedException"

**Cause**: Attempting to create product with existing productId (unlikely with UUID)

**Solution**: This should not occur with randomly generated UUIDs

## Validation Criteria

Your CreateItem function is correctly implemented when:

✅ POST /products with valid body returns 201 Created
✅ Response includes auto-generated `productId` (UUID format)
✅ Response includes `createdAt` and `updatedAt` timestamps
✅ Missing `name` returns 400 with appropriate error
✅ Missing `price` returns 400 with appropriate error
✅ Invalid JSON returns 400 with parse error
✅ Product appears in DynamoDB table
✅ Subsequent GET /products includes the created product
✅ CloudWatch Logs show successful PutItem operation
✅ X-Ray trace displays DynamoDB PutItem segment

## Next Steps

After implementing CreateItem:

1. Deploy with `sam build && sam deploy`
2. Test with curl command
3. Save the returned `productId` for later tests
4. Verify product exists with GET /products
5. Check CloudWatch Logs for execution details
6. Proceed to implement GetItem function
