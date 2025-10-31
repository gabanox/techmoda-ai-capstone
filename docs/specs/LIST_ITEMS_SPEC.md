# Lambda Function Specification: ListItems

## Purpose

Return all products in the TechModa fashion catalog by performing a DynamoDB Scan operation.

## API Endpoint

**Method**: `GET`

**Path**: `/products`

**Trigger**: API Gateway REST API event

## Input Schema

### Path Parameters
None

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
  "path": "/products",
  "headers": { ... },
  "requestContext": { ... },
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
  "products": [
    {
      "productId": "123e4567-e89b-12d3-a456-426614174000",
      "name": "Classic Denim Jacket",
      "description": "Timeless denim jacket for all seasons",
      "price": 79.99,
      "category": "Jackets",
      "imageUrl": "https://example.com/jacket.jpg",
      "createdAt": "2025-10-30T12:00:00.000Z",
      "updatedAt": "2025-10-30T12:00:00.000Z"
    },
    {
      "productId": "987e6543-e21b-45d6-b789-123456789abc",
      "name": "Summer Floral Dress",
      "description": "Lightweight dress perfect for warm weather",
      "price": 59.99,
      "category": "Dresses",
      "imageUrl": "https://example.com/dress.jpg",
      "createdAt": "2025-10-30T13:00:00.000Z",
      "updatedAt": "2025-10-30T13:00:00.000Z"
    }
  ]
}
```

**Empty Database Response**:
```json
{
  "products": []
}
```

### Error Response (500 Internal Server Error)

**HTTP Status Code**: 500

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
  "error": "Internal server error",
  "message": "Failed to retrieve products"
}
```

## DynamoDB Operations

### Operation: Scan

**Purpose**: Retrieve all items from the TechModa-Products table

**AWS SDK v3 Command**: `ScanCommand`

**Parameters**:
```javascript
{
  TableName: process.env.PRODUCTS_TABLE
}
```

**Response**:
```javascript
{
  Items: [
    {
      productId: "123e4567-e89b-12d3-a456-426614174000",
      name: "Classic Denim Jacket",
      // ... other attributes
    }
  ],
  Count: 2,
  ScannedCount: 2
}
```

**Performance Note**: Scan reads the entire table. For production applications with large datasets, consider using Query with a Global Secondary Index. For this capstone scope (< 50 products), Scan is acceptable.

## Implementation Steps (Pseudocode)

```
1. Initialize DynamoDB client and document client
   - Import DynamoDBClient from @aws-sdk/client-dynamodb
   - Import DynamoDBDocumentClient and ScanCommand from @aws-sdk/lib-dynamodb
   - Create client instance
   - Wrap with DocumentClient for simplified JSON handling

2. Define Lambda handler function
   - Async function: exports.handler = async (event)

3. Prepare DynamoDB Scan parameters
   - TableName: process.env.PRODUCTS_TABLE

4. Execute Scan operation
   - Use try/catch for error handling
   - Send ScanCommand to DynamoDB
   - Extract Items array from response

5. Handle success case
   - Wrap Items in response object: { products: Items }
   - Return API Gateway response:
     * statusCode: 200
     * headers: Content-Type and CORS
     * body: JSON.stringify({ products: Items })

6. Handle error case
   - Log error to CloudWatch (console.error)
   - Return API Gateway error response:
     * statusCode: 500
     * headers: Content-Type and CORS
     * body: JSON.stringify({ error: "...", message: "..." })
```

## Testing Curl Command

### Retrieve API Gateway URL

After deploying your SAM stack, get the API URL from CloudFormation outputs:

```bash
aws cloudformation describe-stacks \
  --stack-name techmoda-capstone \
  --query "Stacks[0].Outputs[?OutputKey=='TechModaApi'].OutputValue" \
  --output text
```

### Test Command

```bash
curl -X GET https://{api-id}.execute-api.us-east-1.amazonaws.com/Prod/products
```

### Expected Success Response

```json
{
  "products": [
    {
      "productId": "123e4567-e89b-12d3-a456-426614174000",
      "name": "Classic Denim Jacket",
      "description": "Timeless denim jacket for all seasons",
      "price": 79.99,
      "category": "Jackets",
      "imageUrl": "https://example.com/jacket.jpg",
      "createdAt": "2025-10-30T12:00:00.000Z",
      "updatedAt": "2025-10-30T12:00:00.000Z"
    }
  ]
}
```

### Verify in CloudWatch Logs

```bash
aws logs tail /aws/lambda/techmoda-capstone-ListItems --follow
```

Look for:
- START RequestId line
- Console.log() output showing Scan results
- END RequestId line
- REPORT line showing duration and memory usage

## Claude Code Prompt

Use this prompt to generate the implementation:

```
I need to implement a Lambda function in Node.js 18.x that lists all products from a DynamoDB table.

Requirements:
- Function name: ListItems
- Runtime: Node.js 18.x
- Trigger: API Gateway (GET /products)
- Database: DynamoDB table (name from environment variable PRODUCTS_TABLE)
- Operation: Scan all items
- Response: JSON array of products with HTTP 200
- Error handling: Return HTTP 500 if DynamoDB operation fails
- CORS: Include Access-Control-Allow-Origin: * header

DynamoDB Schema:
- productId (String, primary key)
- name (String)
- description (String)
- price (Number)
- category (String)
- imageUrl (String)
- createdAt (String)
- updatedAt (String)

Please generate:
1. Complete index.js file with exports.handler function
2. AWS SDK v3 imports for DynamoDB
3. Error handling with try/catch
4. API Gateway response format (statusCode, headers, body)
5. Comments explaining each section
```

## Implementation Notes

### Environment Variables

The Lambda function receives the DynamoDB table name via environment variable:

```javascript
const tableName = process.env.PRODUCTS_TABLE;
```

This is injected by the SAM template:

```yaml
Environment:
  Variables:
    PRODUCTS_TABLE: !Ref ProductsTable
```

### AWS SDK v3 Usage

Use the modular AWS SDK v3 for smaller bundle sizes:

```javascript
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
```

### CORS Headers

Include CORS headers in all responses to allow browser-based clients:

```javascript
const headers = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*'
};
```

### Error Logging

Always log errors to CloudWatch for debugging:

```javascript
catch (error) {
  console.error('Error scanning products:', error);
  // Return 500 response
}
```

### API Gateway Response Format

Lambda must return responses in this structure:

```javascript
{
  statusCode: 200,
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
  },
  body: JSON.stringify({ products: [...] })
}
```

**Important**: `body` must be a JSON string, not an object.

## Common Errors and Solutions

### Error: "Cannot find module '@aws-sdk/client-dynamodb'"

**Cause**: AWS SDK not installed in Lambda function directory

**Solution**: Ensure `package.json` exists in `functions/list-items/` with SDK dependencies, or rely on Lambda's built-in SDK (available in Node.js 18.x runtime)

### Error: "PRODUCTS_TABLE is not defined"

**Cause**: Environment variable not set in SAM template

**Solution**: Verify `template.yaml` includes:
```yaml
Environment:
  Variables:
    PRODUCTS_TABLE: !Ref ProductsTable
```

### Error: "AccessDeniedException: User is not authorized to perform: dynamodb:Scan"

**Cause**: Lambda execution role lacks DynamoDB permissions

**Solution**: Add DynamoDB read policy in SAM template:
```yaml
Policies:
  - DynamoDBReadPolicy:
      TableName: !Ref ProductsTable
```

### Error: "undefined is not a function"

**Cause**: Incorrect AWS SDK v3 import

**Solution**: Use DocumentClient for simplified JSON handling:
```javascript
const { DynamoDBDocumentClient, ScanCommand } = require('@aws-sdk/lib-dynamodb');
```

## Validation Criteria

Your ListItems function is correctly implemented when:

✅ GET /products returns 200 OK
✅ Response includes `products` array
✅ Empty database returns `{ "products": [] }`
✅ All product attributes are present (productId, name, price, etc.)
✅ CORS headers are included
✅ DynamoDB Scan errors return 500 with error message
✅ CloudWatch Logs show successful execution
✅ X-Ray trace displays DynamoDB segment

## Next Steps

After implementing ListItems:

1. Deploy with `sam build && sam deploy`
2. Test with curl command
3. Verify response in terminal
4. Check CloudWatch Logs for execution logs
5. Proceed to implement CreateItem function
