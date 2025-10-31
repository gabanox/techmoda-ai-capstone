# Prompt Templates: Testing

These prompts help you test your TechModa API endpoints using curl commands and troubleshoot failed requests.

## Prompt 4.1: Generate Curl Commands for All Endpoints

```
I have deployed my TechModa capstone API and need curl commands to test all 5 endpoints.

API Gateway URL: https://{api-id}.execute-api.us-east-1.amazonaws.com/Prod

Endpoints to test:
1. GET /products (list all)
2. POST /products (create new)
3. GET /products/{id} (get by id)
4. PUT /products/{id} (update)
5. DELETE /products/{id} (delete)

Please provide:
1. Curl command for each endpoint
2. Sample request bodies where applicable
3. Expected response status codes (200, 201, 404)
4. How to capture productId from create response for use in other commands
```

## Prompt 4.2: Debug Failed API Request

```
I'm getting an error when calling my API endpoint.

Endpoint: [GET/POST/PUT/DELETE] /products[/{id}]

Curl command:
[paste your curl command]

Error response:
[paste error response]

Please help me:
1. Interpret the error message
2. Identify likely cause (Lambda error, API Gateway config, DynamoDB permissions)
3. Suggest where to look for logs (CloudWatch Logs)
4. Provide debugging steps
```

## Usage Instructions

### Testing Workflow

Follow this sequence for complete testing:

1. **Create Product** → Get productId
2. **List Products** → Verify product appears
3. **Get Product** → Retrieve by ID
4. **Update Product** → Modify attributes
5. **Delete Product** → Remove from catalog

### Save API URL

```bash
export API_URL="https://abc123xyz.execute-api.us-east-1.amazonaws.com/Prod"
```

### Test All Endpoints

Use prompts to generate specific curl commands for your API.

## Example Test Scenarios

### Scenario 1: Create and Verify Product

**Prompt**:
```
I want to test creating a product and then verifying it exists.

My API URL: [your URL]

Please provide:
1. Curl command to create a product with name "Test Jacket" and price 99.99
2. Command to capture the productId from response
3. Curl command to verify product exists with GET /products
4. Curl command to retrieve specific product by ID
```

### Scenario 2: Update and Verify Changes

**Prompt**:
```
I have created a product and want to test updating it.

Product ID: [your productId]
API URL: [your URL]

Please provide:
1. Curl command to update the price to 79.99
2. Curl command to verify the update worked
3. How to check that updatedAt timestamp changed
```

### Scenario 3: Delete and Verify Removal

**Prompt**:
```
I want to test deleting a product and confirming it's gone.

Product ID: [your productId]
API URL: [your URL]

Please provide:
1. Curl command to delete the product
2. Curl command to verify product no longer exists (should return 404)
3. Curl command to list all products (deleted one shouldn't appear)
```

### Scenario 4: Test Error Handling

**Prompt**:
```
I want to test my API's error handling.

API URL: [your URL]

Please provide curl commands to test:
1. Creating product without required field (name)
2. Getting non-existent product (should return 404)
3. Updating non-existent product (should return 404)
4. Creating product with invalid JSON
```

## Debugging Prompts

### 500 Internal Server Error

```
I'm getting a 500 Internal Server Error from my API.

Endpoint: [endpoint]
HTTP Method: [GET/POST/PUT/DELETE]
Curl command: [paste command]

Response:
{
  "error": "Internal server error",
  "message": "Failed to [action]"
}

Please help me:
1. Identify which Lambda function handles this endpoint
2. Show me how to check CloudWatch Logs for this function
3. What common issues cause 500 errors (DynamoDB permissions, syntax errors, etc.)
4. How to fix the issue
```

### 404 Not Found (Unexpected)

```
I'm getting a 404 Not Found but the product should exist.

Product ID: [productId]
Created with: POST /products at [timestamp]

Curl command:
curl -X GET $API_URL/products/[productId]

Response:
{
  "error": "Not Found",
  "message": "Product not found"
}

Please help me:
1. Verify the productId is correct
2. Check if product exists in DynamoDB
3. Verify GetItem function is working correctly
4. Debug why product isn't being found
```

### 400 Bad Request

```
I'm getting a 400 Bad Request error.

Endpoint: POST /products
Curl command: [paste command]

Response:
{
  "error": "Bad Request",
  "message": "[error message]"
}

Please help me:
1. Check if required fields are provided
2. Verify JSON syntax is correct
3. Identify which validation is failing
4. Fix the request
```

### 403 Forbidden

```
I'm getting a 403 Forbidden error.

Endpoint: [endpoint]
Error: AccessDeniedException

Please help me:
1. Check if Lambda has DynamoDB permissions
2. Verify IAM role policies in template.yaml
3. How to fix permission issues
4. Redeploy if needed
```

### No Response / Timeout

```
My API request is timing out or returning no response.

Endpoint: [endpoint]
Curl command: [paste command]

Behavior: Request hangs for 30 seconds then times out

Please help me:
1. Check if Lambda function is timing out
2. Look for infinite loops or blocking operations
3. Check CloudWatch Logs for timeout errors
4. How to increase Lambda timeout if needed
```

## Advanced Testing Prompts

### Test with jq for Pretty Output

```
I want to format my curl responses with jq for better readability.

Please show me:
1. How to pipe curl output to jq
2. Command to extract specific fields (like productId)
3. How to save response to file and parse it
```

### Test with Postman Alternative

```
I prefer using a GUI tool instead of curl.

Please recommend:
1. Alternative tools to curl (Postman, Insomnia, etc.)
2. How to import my API into the tool
3. How to set up environment variables for API URL
```

### Automated Test Script

```
I want to create a bash script that tests all endpoints automatically.

Please provide:
1. Complete bash script that:
   - Creates a product
   - Lists all products
   - Gets product by ID
   - Updates product
   - Deletes product
2. Error checking at each step
3. Clean output showing pass/fail for each test
```

## Verification Checklist

After testing, verify:

✅ **Create** (POST /products)
   - Returns 201 Created
   - Includes productId in response
   - Product has timestamps

✅ **List** (GET /products)
   - Returns 200 OK
   - Shows all created products
   - Empty array if no products

✅ **Get** (GET /products/{id})
   - Returns 200 OK for existing product
   - Returns 404 for non-existent product
   - Response matches created product

✅ **Update** (PUT /products/{id})
   - Returns 200 OK
   - Updated fields changed
   - updatedAt timestamp newer than createdAt
   - Returns 404 for non-existent product

✅ **Delete** (DELETE /products/{id})
   - Returns 200 OK
   - Subsequent GET returns 404
   - Product removed from list

## Common Issues and Solutions

### Issue: Connection Refused

**Prompt**:
```
Curl is giving me "Connection refused" error.

Error: curl: (7) Failed to connect to [host] port 443: Connection refused

Please help me:
1. Verify my API Gateway URL is correct
2. Check if deployment completed successfully
3. Test connectivity to AWS
```

### Issue: Malformed JSON

**Prompt**:
```
I'm getting JSON parse errors.

My curl command:
[paste command]

Error: Invalid JSON in request body

Please help me:
1. Validate my JSON syntax
2. Check if I need to escape quotes
3. Show correct format for curl -d flag
```

### Issue: CORS Error in Browser

**Prompt**:
```
My API works with curl but fails in browser with CORS error.

Error: Access to fetch at '...' from origin '...' has been blocked by CORS policy

Please help me:
1. Verify CORS headers are in Lambda responses
2. Check if OPTIONS method is configured
3. Fix CORS configuration
```

## Next Steps

After successful testing:

1. Document test results (screenshots optional)
2. Verify CloudWatch Logs show executions
3. Review X-Ray traces
4. Proceed to [Debugging Guide](05_DEBUGGING.md) if issues found
5. Move to [Operations Prompts](06_OPERATIONS.md) for monitoring
