# Prompt Templates: Lambda Implementation

These prompts help you implement all 5 Lambda functions for the TechModa product catalog API using Claude Code.

## Prompt 2.1: Implement ListItems Function

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

## Prompt 2.2: Implement CreateItem Function

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

## Prompt 2.3: Implement GetItem Function

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

## Prompt 2.4: Implement UpdateItem Function

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

## Prompt 2.5: Implement DeleteItem Function

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

## Usage Instructions

### Step 1: Choose the Right Prompt

Start with the function you want to implement:
- **CreateItem first** (recommended) - Allows you to add test data
- Or follow the order in your Function Specifications

### Step 2: Copy the Prompt

Copy the entire prompt (including requirements and schema) to Claude Code.

### Step 3: Generate Implementation

Claude Code will generate a complete `index.js` file with:
- AWS SDK v3 imports
- DynamoDB client initialization
- Lambda handler function
- Error handling
- API Gateway response formatting

### Step 4: Save to Correct Location

Save the generated code to:
```
functions/[function-name]/index.js
```

For example:
- `functions/list-items/index.js`
- `functions/create-item/index.js`
- `functions/get-item/index.js`
- `functions/update-item/index.js`
- `functions/delete-item/index.js`

### Step 5: Review and Deploy

1. Review the generated code
2. Run `sam build` to compile
3. Run `sam deploy` to deploy
4. Test with curl commands

## Follow-Up Prompts

### If Generated Code Has Errors

```
I generated a Lambda function using your code but I'm getting this error:

[Paste error message from CloudWatch Logs or deployment]

Function name: [ListItems/CreateItem/etc]
Error location: [where error occurs]

Please help me:
1. Identify what's causing the error
2. Fix the code
3. Explain why the error happened
```

### If Response Format Is Wrong

```
My Lambda function executes successfully but API Gateway returns a 502 Bad Gateway error.

Function name: [function name]

CloudWatch Logs show:
[Paste relevant log entries]

I think the issue is with the response format. Please help me:
1. Verify the API Gateway response format is correct
2. Check statusCode, headers, and body structure
3. Ensure body is JSON.stringify() not a plain object
```

### If DynamoDB Operation Fails

```
My Lambda function is failing when trying to access DynamoDB.

Function name: [function name]
Operation: [Scan/PutItem/GetItem/UpdateItem/DeleteItem]

Error from CloudWatch:
[Paste error]

Please help me:
1. Check if the DynamoDB client is initialized correctly
2. Verify I'm using AWS SDK v3 syntax
3. Confirm the table name environment variable is being used
4. Check the DynamoDB operation parameters
```

## Common Issues and Solutions

### Issue: AWS SDK Not Found

**Symptom**: `Cannot find module '@aws-sdk/client-dynamodb'`

**Prompt**:
```
My Lambda function has this error: Cannot find module '@aws-sdk/client-dynamodb'

I'm using Node.js 18.x runtime.

Please help me:
1. Understand if AWS SDK v3 is included in Lambda runtime
2. Check if I need a package.json
3. Verify the import statements are correct
```

### Issue: PRODUCTS_TABLE Undefined

**Symptom**: Table name is undefined

**Prompt**:
```
My Lambda function can't find the PRODUCTS_TABLE environment variable.

Error: Table name is undefined

Please help me:
1. Verify I'm correctly reading process.env.PRODUCTS_TABLE
2. Explain how SAM injects environment variables
3. Check my template.yaml configuration
```

### Issue: JSON Parse Error

**Symptom**: `Unexpected token in JSON`

**Prompt**:
```
My CreateItem or UpdateItem function is failing to parse the JSON body.

Error: SyntaxError: Unexpected token in JSON at position X

Please help me:
1. Show me the correct way to parse event.body
2. Explain why event.body is a string, not an object
3. Add try/catch for JSON parse errors
4. Return proper 400 response for invalid JSON
```

## Testing Each Function

After implementing each function, test it:

### Test ListItems
```bash
curl -X GET $API_URL/products
```

### Test CreateItem
```bash
curl -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Product", "price": 99.99}'
```

### Test GetItem
```bash
curl -X GET $API_URL/products/{productId}
```

### Test UpdateItem
```bash
curl -X PUT $API_URL/products/{productId} \
  -H "Content-Type: application/json" \
  -d '{"price": 79.99}'
```

### Test DeleteItem
```bash
curl -X DELETE $API_URL/products/{productId}
```

## Next Steps

After implementing all 5 functions:

1. Test complete CRUD workflow
2. Verify CloudWatch Logs show successful executions
3. Check X-Ray traces
4. Document your implementation in README.md
5. Proceed to [Deployment Prompts](03_DEPLOYMENT.md)
