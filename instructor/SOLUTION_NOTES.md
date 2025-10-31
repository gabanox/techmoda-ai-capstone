# TechModa Capstone - Solution Notes

## Purpose

This document provides implementation patterns and guidance for instructors. It does NOT contain complete solutions to avoid temptation to share with students. Instead, it offers:

- Key implementation patterns for each function
- Common mistakes students make
- Best practices examples
- Security and performance considerations

**DO NOT share this file with students**. Direct them to specifications and prompt templates instead.

## General Implementation Patterns

### AWS SDK v3 Setup

All Lambda functions should initialize DynamoDB client this way:

```javascript
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand, PutCommand, GetCommand, UpdateCommand, DeleteCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
```

**Why DocumentClient?**: Simplifies JSON marshalling/unmarshalling (no need to specify types like `{S: "value"}`).

### API Gateway Response Format

Every Lambda must return this structure:

```javascript
return {
  statusCode: 200,  // Must be number, not string
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
  },
  body: JSON.stringify({...})  // Must be string, not object
};
```

**Common Mistakes**:
- Returning object instead of stringified JSON
- Missing CORS headers
- statusCode as string ("200" instead of 200)

### Environment Variables

Always use environment variable for table name:

```javascript
const tableName = process.env.PRODUCTS_TABLE;
```

**Never hardcode**: `const tableName = "techmoda-capstone-Products";` (breaks when deployed to different environments)

## Function-Specific Patterns

### ListItems (GET /products)

**Key Operations**:
1. Perform DynamoDB Scan
2. Return items array wrapped in `products` field
3. Handle empty table gracefully

**Scan Command**:
```javascript
const result = await docClient.send(new ScanCommand({
  TableName: process.env.PRODUCTS_TABLE
}));

// result.Items is an array (empty array if no items)
```

**Success Response**:
```javascript
return {
  statusCode: 200,
  headers: {...},
  body: JSON.stringify({ products: result.Items || [] })
};
```

**Common Mistakes**:
- Not handling empty Items array (should return empty products array, not error)
- Returning `result` directly instead of wrapping in `{ products: [...] }`
- Not including CORS headers

**Performance Note**: Scan reads entire table. For capstone scope (< 50 items), this is acceptable. In production, use Query with GSI for large datasets.

### CreateItem (POST /products)

**Key Operations**:
1. Parse JSON body safely
2. Validate required fields (name, price)
3. Generate UUID for productId
4. Add timestamps
5. Perform DynamoDB PutItem
6. Return created item with 201 status

**JSON Parsing**:
```javascript
let body;
try {
  body = JSON.parse(event.body);
} catch (error) {
  return {
    statusCode: 400,
    headers: {...},
    body: JSON.stringify({ error: 'Bad Request', message: 'Invalid JSON' })
  };
}
```

**Validation**:
```javascript
if (!body.name) {
  return {
    statusCode: 400,
    headers: {...},
    body: JSON.stringify({ error: 'Bad Request', message: 'Missing required field: name' })
  };
}

if (body.price === undefined || body.price === null) {
  return {
    statusCode: 400,
    headers: {...},
    body: JSON.stringify({ error: 'Bad Request', message: 'Missing required field: price' })
  };
}
```

**UUID Generation**:
```javascript
const crypto = require('crypto');
const productId = crypto.randomUUID();
```

**Timestamps**:
```javascript
const now = new Date().toISOString();
const product = {
  productId,
  name: body.name,
  description: body.description || '',
  price: body.price,
  category: body.category || '',
  imageUrl: body.imageUrl || '',
  createdAt: now,
  updatedAt: now
};
```

**PutItem Command**:
```javascript
await docClient.send(new PutCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Item: product
}));
```

**Success Response** (note 201, not 200):
```javascript
return {
  statusCode: 201,
  headers: {...},
  body: JSON.stringify(product)
};
```

**Common Mistakes**:
- Not parsing event.body (treating it as object instead of string)
- Not validating required fields
- Returning 200 instead of 201
- Not generating UUID (expecting client to provide)
- Missing timestamps

### GetItem (GET /products/{id})

**Key Operations**:
1. Extract productId from path parameters
2. Perform DynamoDB GetItem
3. Return 200 if found, 404 if not found

**Path Parameter Extraction**:
```javascript
const productId = event.pathParameters.id;

// Optional safety check:
if (!productId) {
  return {
    statusCode: 400,
    headers: {...},
    body: JSON.stringify({ error: 'Bad Request', message: 'Missing product ID' })
  };
}
```

**GetItem Command**:
```javascript
const result = await docClient.send(new GetCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: { productId }
}));
```

**Check Existence**:
```javascript
if (!result.Item) {
  return {
    statusCode: 404,
    headers: {...},
    body: JSON.stringify({ error: 'Not Found', message: 'Product not found' })
  };
}

return {
  statusCode: 200,
  headers: {...},
  body: JSON.stringify(result.Item)
};
```

**Common Mistakes**:
- Not checking if Item exists (returning undefined instead of 404)
- Trying to access event.pathParameters without checking if it exists
- Crashing when productId is invalid

**Performance**: GetItem is fastest DynamoDB operation (single-digit milliseconds).

### UpdateItem (PUT /products/{id})

**Key Operations**:
1. Extract productId from path parameters
2. Parse update fields from body
3. Check if product exists (optional but recommended)
4. Build dynamic UpdateExpression
5. Update updatedAt timestamp
6. Perform DynamoDB UpdateItem
7. Return updated item

**Existence Check** (recommended):
```javascript
const getResult = await docClient.send(new GetCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: { productId }
}));

if (!getResult.Item) {
  return {
    statusCode: 404,
    headers: {...},
    body: JSON.stringify({ error: 'Not Found', message: 'Product not found' })
  };
}
```

**Dynamic UpdateExpression Building**:
```javascript
const updates = [];
const values = {};

if (body.name !== undefined) {
  updates.push('name = :name');
  values[':name'] = body.name;
}

if (body.price !== undefined) {
  updates.push('price = :price');
  values[':price'] = body.price;
}

if (body.description !== undefined) {
  updates.push('description = :description');
  values[':description'] = body.description;
}

if (body.category !== undefined) {
  updates.push('category = :category');
  values[':category'] = body.category;
}

if (body.imageUrl !== undefined) {
  updates.push('imageUrl = :imageUrl');
  values[':imageUrl'] = body.imageUrl;
}

// Always update timestamp
updates.push('updatedAt = :updatedAt');
values[':updatedAt'] = new Date().toISOString();

const updateExpression = 'SET ' + updates.join(', ');
```

**UpdateItem Command**:
```javascript
const result = await docClient.send(new UpdateCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: { productId },
  UpdateExpression: updateExpression,
  ExpressionAttributeValues: values,
  ReturnValues: 'ALL_NEW'
}));

return {
  statusCode: 200,
  headers: {...},
  body: JSON.stringify(result.Attributes)
};
```

**Common Mistakes**:
- Not building UpdateExpression dynamically (failing on partial updates)
- Hardcoding field names instead of using ExpressionAttributeValues
- Not updating updatedAt timestamp
- Forgetting `ReturnValues: 'ALL_NEW'` (won't get updated item back)
- Allowing updates to productId or createdAt (should be immutable)

**Alternative (Simpler but Less Flexible)**:
Update all fields even if not provided. Less code but overwrites with undefined/null.

### DeleteItem (DELETE /products/{id})

**Key Operations**:
1. Extract productId from path parameters
2. Optionally check existence first
3. Perform DynamoDB DeleteItem
4. Return success message

**Simple Implementation** (no existence check):
```javascript
await docClient.send(new DeleteCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: { productId }
}));

return {
  statusCode: 200,
  headers: {...},
  body: JSON.stringify({
    message: 'Product deleted successfully',
    productId
  })
};
```

**Advanced Implementation** (with existence check):
```javascript
// Check existence first
const getResult = await docClient.send(new GetCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: { productId }
}));

if (!getResult.Item) {
  return {
    statusCode: 404,
    headers: {...},
    body: JSON.stringify({ error: 'Not Found', message: 'Product not found' })
  };
}

// Delete if exists
await docClient.send(new DeleteCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: { productId }
}));

return {
  statusCode: 200,
  headers: {...},
  body: JSON.stringify({
    message: 'Product deleted successfully',
    productId
  })
};
```

**Using ReturnValues** (alternative approach):
```javascript
const result = await docClient.send(new DeleteCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: { productId },
  ReturnValues: 'ALL_OLD'
}));

if (!result.Attributes) {
  return {
    statusCode: 404,
    headers: {...},
    body: JSON.stringify({ error: 'Not Found', message: 'Product not found' })
  };
}

return {
  statusCode: 200,
  headers: {...},
  body: JSON.stringify({
    message: 'Product deleted successfully',
    deletedProduct: result.Attributes
  })
};
```

**Common Mistakes**:
- Not understanding DeleteItem is idempotent (succeeds even if item doesn't exist)
- Confusing about whether to check existence first (both approaches valid)

**Design Decision**: Simple implementation (no existence check) is acceptable for capstone. Advanced implementation (with check) demonstrates better error handling.

## Common Mistakes Students Make

### 1. API Gateway Response Format Issues

**Mistake**:
```javascript
return { products: [...] };  // ❌ Wrong
```

**Correct**:
```javascript
return {
  statusCode: 200,
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
  },
  body: JSON.stringify({ products: [...] })
};
```

### 2. Treating event.body as Object

**Mistake**:
```javascript
const name = event.body.name;  // ❌ event.body is a string
```

**Correct**:
```javascript
const body = JSON.parse(event.body);
const name = body.name;
```

### 3. Not Awaiting Async Operations

**Mistake**:
```javascript
docClient.send(new GetCommand({...}));  // ❌ Not awaited
return { statusCode: 200, ... };
```

**Correct**:
```javascript
const result = await docClient.send(new GetCommand({...}));
return { statusCode: 200, body: JSON.stringify(result.Item) };
```

### 4. Hardcoded Table Names

**Mistake**:
```javascript
const tableName = "TechModa-Products";  // ❌ Breaks in other environments
```

**Correct**:
```javascript
const tableName = process.env.PRODUCTS_TABLE;
```

### 5. Missing Error Handling

**Mistake**:
```javascript
exports.handler = async (event) => {
  const result = await docClient.send(...);  // ❌ No try/catch
  return { statusCode: 200, ... };
};
```

**Correct**:
```javascript
exports.handler = async (event) => {
  try {
    const result = await docClient.send(...);
    return { statusCode: 200, ... };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: {...},
      body: JSON.stringify({ error: 'Internal server error', message: error.message })
    };
  }
};
```

### 6. Incorrect DynamoDB SDK Syntax

**Mistake** (SDK v2 syntax in Node.js 18):
```javascript
const result = await docClient.scan({ TableName: tableName }).promise();  // ❌ SDK v2
```

**Correct** (SDK v3):
```javascript
const result = await docClient.send(new ScanCommand({ TableName: tableName }));
```

### 7. Missing CORS Headers

**Symptom**: API works in curl but fails in browser

**Fix**: Add to all responses:
```javascript
headers: {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*'
}
```

### 8. Wrong Status Codes

**Mistakes**:
- CreateItem returning 200 (should be 201)
- GetItem returning 500 when item not found (should be 404)
- statusCode as string: `statusCode: "200"` (should be number)

## Advanced Features (Beyond Scope)

Students may ask about these. They're NOT required but demonstrate initiative:

### Input Sanitization

```javascript
// Prevent XSS, SQL injection (though DynamoDB isn't SQL)
const sanitize = (str) => str.trim().substring(0, 1000);

const product = {
  productId,
  name: sanitize(body.name),
  description: sanitize(body.description || ''),
  // ...
};
```

### Pagination (ListItems)

```javascript
// For large datasets, use pagination
const params = {
  TableName: process.env.PRODUCTS_TABLE,
  Limit: 20
};

if (event.queryStringParameters && event.queryStringParameters.lastKey) {
  params.ExclusiveStartKey = JSON.parse(event.queryStringParameters.lastKey);
}

const result = await docClient.send(new ScanCommand(params));

return {
  statusCode: 200,
  headers: {...},
  body: JSON.stringify({
    products: result.Items,
    lastKey: result.LastEvaluatedKey ? JSON.stringify(result.LastEvaluatedKey) : null
  })
};
```

### Field-Level Validation

```javascript
// Validate price is positive number
if (typeof body.price !== 'number' || body.price <= 0) {
  return {
    statusCode: 400,
    headers: {...},
    body: JSON.stringify({ error: 'Bad Request', message: 'Price must be a positive number' })
  };
}

// Validate URL format
const urlRegex = /^https?:\/\/.+/;
if (body.imageUrl && !urlRegex.test(body.imageUrl)) {
  return {
    statusCode: 400,
    headers: {...},
    body: JSON.stringify({ error: 'Bad Request', message: 'Invalid image URL format' })
  };
}
```

### Conditional Updates

```javascript
// Only update if item hasn't changed (optimistic locking)
const updateCommand = new UpdateCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: { productId },
  UpdateExpression: 'SET price = :price, updatedAt = :updatedAt',
  ConditionExpression: 'updatedAt = :oldUpdatedAt',
  ExpressionAttributeValues: {
    ':price': body.price,
    ':updatedAt': new Date().toISOString(),
    ':oldUpdatedAt': body.expectedUpdatedAt  // Client provides expected timestamp
  },
  ReturnValues: 'ALL_NEW'
});
```

## Security Considerations

### What Students Should DO

✅ Use environment variables for configuration
✅ Implement least-privilege IAM policies
✅ Include CORS headers for browser compatibility
✅ Validate input data
✅ Log errors (but not sensitive data)
✅ Return appropriate error messages (not stack traces to clients)

### What Students Should NOT DO

❌ Hardcode AWS credentials in code
❌ Use wildcard IAM policies (`"Resource": "*"`)
❌ Return detailed stack traces in API responses
❌ Log sensitive data (credit cards, passwords)
❌ Allow SQL injection (not applicable with DynamoDB but good habit)

### Production Considerations (Beyond Capstone)

- Add authentication (Cognito, API keys)
- Implement rate limiting
- Add request validation (API Gateway request validators)
- Use AWS WAF for additional security
- Encrypt sensitive data at rest
- Enable CloudTrail for auditing

## Performance Optimization

### What Matters for Capstone

- Use GetItem over Scan when possible (GetItem for single item retrieval)
- Keep Lambda function code small (fewer dependencies = faster cold starts)
- Set appropriate timeout (30s is fine for capstone, but some functions might need less)

### What Doesn't Matter for Capstone

- Lambda provisioned concurrency (unnecessary for low traffic)
- DynamoDB provisioned capacity (PAY_PER_REQUEST is simpler and cheaper for this scale)
- VPC configuration (not needed for simple DynamoDB access)
- Lambda layers (overkill for this project)

### Cold Start Optimization (Advanced)

Students may notice first request after deployment is slow (~1-2 seconds). This is **cold start**.

**Explanation**: Lambda initializes runtime, loads code, creates DynamoDB client
**Mitigation (production)**: Provisioned concurrency, Lambda SnapStart
**For capstone**: Accept cold starts (happens once per ~15 minutes of inactivity)

## Troubleshooting Guide for Instructors

### Quick Diagnostics

**Student says "it doesn't work"**:
1. Ask: "What specific error do you see?"
2. Check: CloudWatch Logs (most issues show here)
3. Verify: Deployment succeeded
4. Test: Simple curl command

**CloudWatch Log Errors to Look For**:
- `Cannot find module`: Missing SDK import
- `is not a function`: Wrong SDK syntax (v2 vs v3)
- `AccessDeniedException`: IAM permission issue
- `SyntaxError`: JSON parse error
- `Cannot read property 'X' of undefined`: Missing path parameter or body

### Common Fixes

**500 Error → Check Lambda Code**:
```bash
aws logs tail /aws/lambda/techmoda-capstone-[FunctionName] --follow
```

**403 Forbidden → Check IAM Policies**:
Verify template.yaml has correct policies:
```yaml
Policies:
  - DynamoDBCrudPolicy:
      TableName: !Ref ProductsTable
```

**502 Bad Gateway → Check Response Format**:
Ensure Lambda returns:
- statusCode (number)
- headers (object)
- body (string)

## Testing Reference

### Minimal Working Test

```bash
# Set API URL
export API_URL="https://[api-id].execute-api.us-east-1.amazonaws.com/Prod"

# Create product
curl -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","price":99.99}'

# List products
curl -X GET $API_URL/products

# Expected: { "products": [ {...} ] }
```

If this works, basic infrastructure is functional.

## Best Practices for Code Review

When reviewing student code, look for:

1. **Error Handling**: Try/catch blocks present
2. **Input Validation**: Required fields checked
3. **CORS**: Headers in all responses
4. **Async/Await**: Proper use with DynamoDB operations
5. **Environment Variables**: Not hardcoded
6. **Comments**: Key logic explained
7. **Formatting**: Consistent indentation
8. **No Dead Code**: No commented-out sections

## Resources for Instructors

### AWS Documentation

- [AWS SAM Developer Guide](https://docs.aws.amazon.com/serverless-application-model/)
- [DynamoDB SDK v3 (JavaScript)](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/clients/client-dynamodb/)
- [Lambda Node.js Runtime](https://docs.aws.amazon.com/lambda/latest/dg/lambda-nodejs.html)
- [API Gateway Lambda Proxy Integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html)

### Useful Commands

```bash
# View stack resources
aws cloudformation list-stack-resources --stack-name techmoda-capstone

# Get API URL
aws cloudformation describe-stacks --stack-name techmoda-capstone --query "Stacks[0].Outputs"

# Scan DynamoDB table
aws dynamodb scan --table-name techmoda-capstone-Products

# Tail Lambda logs
aws logs tail /aws/lambda/techmoda-capstone-ListItems --follow

# Delete stack
sam delete --stack-name techmoda-capstone
```

---

**Remember**: Guide students to discover solutions themselves. Use prompts and specifications to support learning, not provide complete answers.
