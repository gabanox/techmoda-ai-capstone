# Lambda Function Specification: UpdateItem

## Purpose

Update an existing product in the TechModa fashion catalog using DynamoDB UpdateItem operation with partial updates and automatic timestamp management.

## API Endpoint

**Method**: `PUT`

**Path**: `/products/{id}`

**Trigger**: API Gateway REST API event with path parameter and JSON body

## Input Schema

### Path Parameters

**Required**: `id` (productId)

**Example**: `/products/123e4567-e89b-12d3-a456-426614174000`

### Query Parameters
None

### Request Headers
```
Content-Type: application/json
```

### Request Body

**Partial Update**: Only include fields to update

**Updateable Fields**: `name`, `description`, `price`, `category`, `imageUrl`

**Non-Updateable Fields**: `productId`, `createdAt` (maintained by system)

**Example**:
```json
{
  "price": 69.99,
  "description": "Updated: Now on sale!"
}
```

**Another Example**:
```json
{
  "name": "Vintage Denim Jacket",
  "price": 89.99,
  "category": "Vintage"
}
```

### API Gateway Event Structure
```javascript
{
  "httpMethod": "PUT",
  "path": "/products/123e4567-e89b-12d3-a456-426614174000",
  "pathParameters": {
    "id": "123e4567-e89b-12d3-a456-426614174000"
  },
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "{\"price\":69.99,\"description\":\"Updated description\"}"
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
  "productId": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Classic Denim Jacket",
  "description": "Updated: Now on sale!",
  "price": 69.99,
  "category": "Jackets",
  "imageUrl": "https://example.com/denim-jacket.jpg",
  "createdAt": "2025-10-30T12:00:00.000Z",
  "updatedAt": "2025-10-30T14:30:00.000Z"
}
```

**Note**: `updatedAt` is newer than `createdAt`

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

#### 400 Bad Request (Invalid Data)

**HTTP Status Code**: 400

**Body**:
```json
{
  "error": "Bad Request",
  "message": "Invalid update data"
}
```

#### 500 Internal Server Error

**HTTP Status Code**: 500

**Body**:
```json
{
  "error": "Internal server error",
  "message": "Failed to update product"
}
```

## DynamoDB Operations

### Operation 1: GetItem (Check Existence)

**Purpose**: Verify product exists before updating

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

### Operation 2: UpdateItem (Perform Update)

**Purpose**: Update specific attributes

**AWS SDK v3 Command**: `UpdateCommand`

**Parameters**:
```javascript
{
  TableName: process.env.PRODUCTS_TABLE,
  Key: {
    productId: "123e4567-e89b-12d3-a456-426614174000"
  },
  UpdateExpression: "SET price = :price, description = :description, updatedAt = :updatedAt",
  ExpressionAttributeValues: {
    ":price": 69.99,
    ":description": "Updated description",
    ":updatedAt": "2025-10-30T14:30:00.000Z"
  },
  ReturnValues: "ALL_NEW"
}
```

**Response**:
```javascript
{
  Attributes: {
    productId: "123e4567-e89b-12d3-a456-426614174000",
    name: "Classic Denim Jacket",
    description: "Updated description",
    price: 69.99,
    // ... all attributes with updates applied
  }
}
```

## Implementation Steps (Pseudocode)

```
1. Initialize DynamoDB client
   - Import DynamoDBClient from @aws-sdk/client-dynamodb
   - Import DynamoDBDocumentClient, GetCommand, UpdateCommand from @aws-sdk/lib-dynamodb
   - Create and wrap client

2. Define Lambda handler function
   - Async function: exports.handler = async (event)

3. Extract productId from path parameters
   - const productId = event.pathParameters.id

4. Parse request body
   - Use try/catch for JSON.parse(event.body)
   - If parse fails, return 400 Bad Request

5. Check if product exists
   - Execute GetItem with productId
   - If Item is undefined, return 404 Not Found

6. Build UpdateExpression dynamically
   - Iterate through update fields (price, name, description, category, imageUrl)
   - Build SET clause: "SET price = :price, name = :name, ..."
   - Add updatedAt to expression
   - Build ExpressionAttributeValues object

7. Execute UpdateItem operation
   - Use try/catch for error handling
   - Send UpdateCommand to DynamoDB
   - Set ReturnValues: "ALL_NEW" to get updated item
   - Extract Attributes from response

8. Handle success case
   - Return API Gateway response:
     * statusCode: 200
     * headers: Content-Type and CORS
     * body: JSON.stringify(Attributes)

9. Handle error cases
   - 404 if product not found in step 5
   - 400 if no valid update fields provided
   - 500 for DynamoDB errors
   - Log errors to CloudWatch
```

## Testing Curl Command

### Update Price and Description

```bash
curl -X PUT $API_URL/products/{PRODUCT_ID} \
  -H "Content-Type: application/json" \
  -d '{
    "price": 69.99,
    "description": "Updated: Timeless denim jacket now on sale!"
  }'
```

### Update Multiple Fields

```bash
curl -X PUT $API_URL/products/{PRODUCT_ID} \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Vintage Denim Jacket",
    "price": 89.99,
    "category": "Vintage",
    "description": "Rare vintage find"
  }'
```

### Update Single Field

```bash
curl -X PUT $API_URL/products/{PRODUCT_ID} \
  -H "Content-Type: application/json" \
  -d '{
    "price": 59.99
  }'
```

### Test 404 Not Found

```bash
curl -X PUT $API_URL/products/nonexistent-id \
  -H "Content-Type: application/json" \
  -d '{"price": 99.99}'
```

**Expected**: 404 Not Found

### Complete Test Workflow

```bash
# 1. Create product
RESPONSE=$(curl -s -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Product", "price": 100.00}')

# 2. Extract productId
PRODUCT_ID=$(echo $RESPONSE | jq -r '.productId')
echo "Created product: $PRODUCT_ID"

# 3. Update product
curl -X PUT $API_URL/products/$PRODUCT_ID \
  -H "Content-Type: application/json" \
  -d '{"price": 79.99, "description": "Updated"}' | jq .

# 4. Verify update
curl -X GET $API_URL/products/$PRODUCT_ID | jq .
```

### Expected Success Response

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

**Verify**: `updatedAt` is newer than `createdAt`

## Claude Code Prompt

```
I need to implement a Lambda function in Node.js 18.x that updates an existing product in DynamoDB.

Requirements:
- Function name: UpdateItem
- Runtime: Node.js 18.x
- Trigger: API Gateway (PUT /products/{id} with JSON body)
- Path parameter: id (productId)
- Database: DynamoDB table (name from environment variable PRODUCTS_TABLE)
- Check if product exists before updating
- Update only provided fields (partial update)
- Update timestamp: updatedAt (ISO 8601 format)
- Response: Updated product with HTTP 200
- Response: Error with HTTP 404 if product not found
- Error handling: 500 for DynamoDB errors
- CORS: Include Access-Control-Allow-Origin: * header

Input JSON body (partial):
{
  "price": 69.99,
  "description": "Updated description"
}

Please generate:
1. Complete index.js with exports.handler
2. Extract productId from path parameters
3. Parse update fields from body
4. Check product exists (GetItem first)
5. Update timestamp
6. AWS SDK v3 DynamoDB UpdateItem
7. Return 404 if not found
8. API Gateway response format
```

## Implementation Notes

### Dynamic UpdateExpression

Build UpdateExpression based on provided fields:

```javascript
const updateFields = [];
const expressionAttributeValues = {};

if (body.name) {
  updateFields.push('name = :name');
  expressionAttributeValues[':name'] = body.name;
}

if (body.price !== undefined) {
  updateFields.push('price = :price');
  expressionAttributeValues[':price'] = body.price;
}

if (body.description) {
  updateFields.push('description = :description');
  expressionAttributeValues[':description'] = body.description;
}

// Always update timestamp
updateFields.push('updatedAt = :updatedAt');
expressionAttributeValues[':updatedAt'] = new Date().toISOString();

const updateExpression = 'SET ' + updateFields.join(', ');
```

### ReturnValues: ALL_NEW

Request DynamoDB to return the updated item:

```javascript
const result = await docClient.send(new UpdateCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: { productId },
  UpdateExpression: updateExpression,
  ExpressionAttributeValues: expressionAttributeValues,
  ReturnValues: 'ALL_NEW'
}));

const updatedProduct = result.Attributes;
```

**Alternative**: `ReturnValues: 'UPDATED_NEW'` returns only modified attributes (not recommended for this use case).

### Preventing productId Updates

Do NOT allow updating the primary key:

```javascript
// Remove productId from update body if present
delete body.productId;
delete body.createdAt; // Also protect createdAt
```

### Timestamp Management

- **createdAt**: Never updated (set only on create)
- **updatedAt**: Updated on every modification

## Common Errors and Solutions

### Error: "ValidationException: Invalid UpdateExpression"

**Cause**: Syntax error in UpdateExpression

**Solution**: Ensure proper format:
```javascript
"SET price = :price, name = :name"
```

Not:
```javascript
"SET price = 69.99" // Wrong: can't use literal values
```

### Error: "Product not found" (but product exists)

**Cause**: GetItem check not properly implemented

**Solution**: Verify GetItem returns Item before proceeding to UpdateItem

### Error: "Cannot read property 'Attributes' of undefined"

**Cause**: UpdateItem failed or didn't return Attributes

**Solution**: Check `ReturnValues: 'ALL_NEW'` is set and operation succeeded

### Error: "ExpressionAttributeValues contains invalid key"

**Cause**: Attribute names start with `:` but provided names don't

**Solution**: Use `:` prefix in ExpressionAttributeValues:
```javascript
{
  ':price': 69.99,  // Correct
  'price': 69.99    // Wrong
}
```

## Validation Criteria

Your UpdateItem function is correctly implemented when:

✅ PUT /products/{id} with valid data returns 200 OK
✅ Response contains updated product with new values
✅ `updatedAt` timestamp is newer than `createdAt`
✅ Unchanged fields remain the same
✅ Partial updates work (can update just one field)
✅ PUT to non-existent ID returns 404 Not Found
✅ Subsequent GET verifies updates persisted
✅ CloudWatch Logs show GetItem and UpdateItem operations
✅ X-Ray trace displays two DynamoDB segments
✅ CORS headers present in all responses

## Next Steps

After implementing UpdateItem:

1. Deploy with `sam build && sam deploy`
2. Create a product with POST /products
3. Save the productId
4. Update with PUT /products/{id}
5. Verify response shows updated values
6. GET the product to confirm persistence
7. Try updating non-existent ID (verify 404)
8. Check CloudWatch Logs
9. Proceed to implement DeleteItem function
