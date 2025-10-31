# Prompt Templates: Debugging

These prompts help you troubleshoot Lambda execution errors, DynamoDB permission issues, and common serverless problems.

## Prompt 5.1: Analyze CloudWatch Logs

```
My Lambda function is failing and I need to analyze CloudWatch Logs.

Function name: [ListItems/CreateItem/GetItem/UpdateItem/DeleteItem]

Error seen in API response:
[paste error]

Please provide:
1. AWS CLI command to retrieve recent logs for this function
2. How to filter logs for errors
3. Common error patterns to look for
4. How to interpret stack traces
```

## Prompt 5.2: Fix DynamoDB Permission Error

```
My Lambda function is failing with a DynamoDB permission error:

Error: AccessDeniedException: User is not authorized to perform dynamodb:Scan/PutItem/GetItem/UpdateItem/DeleteItem

Function: [function name]
Operation: [Scan/PutItem/etc]
Table: TechModa-Products

I am using SAM template with DynamoDB policies.

Please help:
1. Check if SAM policy is correct
2. Verify IAM role has necessary permissions
3. Commands to check current IAM role permissions
4. How to fix permission issue
```

## Prompt 5.3: Debug Lambda Timeout

```
My Lambda function is timing out after 30 seconds.

Function: [function name]
Operation: [what it's doing]

Please help:
1. Where to check current timeout setting
2. How to increase timeout in SAM template
3. Why function might be slow (DynamoDB connection, large scans)
4. How to add logging to measure execution time
5. Redeploy steps after changing timeout
```

## Prompt 5.4: Fix JSON Parse Error

```
My Lambda function is failing to parse JSON body from API Gateway.

Error: SyntaxError: Unexpected token in JSON at position X

Function: CreateItem or UpdateItem

Please help:
1. How API Gateway passes body to Lambda (event.body is a string)
2. Proper way to parse JSON in Node.js (JSON.parse)
3. How to handle invalid JSON (try/catch)
4. Return proper 400 Bad Request response
5. Sample code for safe JSON parsing
```

## Detailed Debugging Workflows

### Workflow 1: Lambda Function Crashes

**Symptoms**:
- 500 Internal Server Error from API
- No response or timeout
- CloudWatch Logs show error

**Debugging Prompt**:
```
My Lambda function is crashing with this error in CloudWatch Logs:

[Paste error and stack trace from CloudWatch]

Function: [function name]
Timestamp: [when error occurred]

Please help me:
1. Identify the root cause of the crash
2. Locate the exact line causing the error
3. Suggest a fix
4. Explain how to prevent similar errors
```

### Workflow 2: DynamoDB Operation Fails

**Symptoms**:
- 500 error mentioning DynamoDB
- AccessDeniedException or ValidationException
- Function executes but can't access database

**Debugging Prompt**:
```
My Lambda function can execute but DynamoDB operations are failing.

Error from CloudWatch:
[Paste DynamoDB error]

Function: [function name]
DynamoDB operation: [Scan/PutItem/GetItem/UpdateItem/DeleteItem]

Please help me:
1. Verify DynamoDB table exists
2. Check Lambda has correct permissions
3. Validate operation parameters
4. Check table name environment variable
5. Fix the issue
```

### Workflow 3: Wrong Response Format

**Symptoms**:
- 502 Bad Gateway from API Gateway
- Lambda executes successfully
- CloudWatch shows no errors

**Debugging Prompt**:
```
My Lambda function completes successfully but API Gateway returns 502 Bad Gateway.

CloudWatch Logs show the function returned:
[Paste return value from logs]

Please help me:
1. Verify API Gateway response format requirements
2. Check statusCode is a number, not a string
3. Confirm body is JSON.stringify(), not an object
4. Verify headers object is correct
5. Fix the response format
```

### Workflow 4: Path Parameter Not Found

**Symptoms**:
- GetItem/UpdateItem/DeleteItem return errors
- "Cannot read property 'id' of undefined"
- Functions work in ListItems but not others

**Debugging Prompt**:
```
My Lambda function is failing to read path parameters.

Error: Cannot read property 'id' of undefined

Function: [GetItem/UpdateItem/DeleteItem]

CloudWatch Logs show:
[Paste relevant logs]

Please help me:
1. Verify event.pathParameters exists
2. Check API Gateway route configuration
3. Show correct way to extract path parameters
4. Add safety checks for missing parameters
```

## Common Error Patterns

### Pattern 1: AWS SDK Import Errors

**Error**: `Cannot find module '@aws-sdk/client-dynamodb'`

**Debugging Prompt**:
```
I'm getting module not found errors for AWS SDK.

Error: Cannot find module '@aws-sdk/client-dynamodb'

Runtime: Node.js 18.x

Please help:
1. Confirm AWS SDK v3 is included in Node.js 18.x Lambda runtime
2. Verify import syntax is correct
3. Check if I need package.json
4. Show correct import statements
```

### Pattern 2: Environment Variable Undefined

**Error**: Table name is undefined

**Debugging Prompt**:
```
My Lambda function can't access environment variables.

Error: Cannot read property 'PRODUCTS_TABLE' of undefined

or

Table name is undefined

Please help:
1. Show correct way to read process.env.PRODUCTS_TABLE
2. Verify SAM template injects environment variables
3. Check template.yaml Environment section
4. Debug why variable isn't available
```

### Pattern 3: DynamoDB SDK v2 vs v3

**Error**: `docClient.scan is not a function`

**Debugging Prompt**:
```
I'm getting errors with DynamoDB SDK methods.

Error: docClient.scan is not a function

I think I might be mixing SDK v2 and v3 syntax.

Please help:
1. Show correct AWS SDK v3 syntax
2. Explain difference between SDK v2 and v3
3. Provide v3 examples for all operations (Scan, PutItem, GetItem, UpdateItem, DeleteItem)
4. Fix my code
```

### Pattern 4: Async/Await Issues

**Error**: Lambda returns undefined or doesn't wait for DynamoDB

**Debugging Prompt**:
```
My Lambda function is returning undefined or not waiting for DynamoDB operations.

Function code:
[Paste relevant code]

Please help:
1. Verify I'm using async/await correctly
2. Check if I'm awaiting DynamoDB calls
3. Confirm handler function is async
4. Fix async flow
```

## CloudWatch Logs Analysis

### View Recent Logs

**Prompt**:
```
I need to view the most recent logs for my Lambda function.

Function name: techmoda-capstone-[FunctionName]

Please provide:
1. AWS CLI command to tail logs in real-time
2. Command to view last 50 log events
3. How to filter for ERROR level logs
4. How to search logs for specific text
```

### Interpret Log Entries

**Prompt**:
```
I'm looking at CloudWatch Logs but don't understand the output.

Log entries:
[Paste several log lines]

Please explain:
1. What START/END/REPORT lines mean
2. How to find my console.log() output
3. What the REPORT line metrics indicate (Duration, Billed Duration, Memory)
4. How to identify errors in the logs
```

## Performance Debugging

### Slow Function Execution

**Prompt**:
```
My Lambda function is taking a long time to execute.

Function: [function name]
Average duration: [X seconds]
Expected duration: [Y seconds]

CloudWatch REPORT line:
[Paste REPORT line]

Please help:
1. Identify what's causing slowness
2. Check if it's a cold start issue
3. Optimize DynamoDB operations
4. Add timing logs to isolate slow sections
```

### Memory Issues

**Prompt**:
```
My Lambda function is running out of memory or using more than expected.

Memory Size: 1024 MB
Max Memory Used: [X MB]

CloudWatch REPORT shows:
[Paste REPORT line]

Please help:
1. Identify what's consuming memory
2. Check for memory leaks
3. Optimize memory usage
4. Determine if I need more memory
```

## Validation and Testing

### Validate Lambda Code Locally

**Prompt**:
```
I want to test my Lambda function locally before deploying.

Function: [function name]

Please show me:
1. How to use sam local invoke
2. How to create test events
3. How to debug locally with breakpoints
4. How to test with local DynamoDB
```

### Validate API Gateway Integration

**Prompt**:
```
My Lambda function works locally but fails when invoked via API Gateway.

Please help:
1. Understand how API Gateway transforms requests
2. Verify event structure from API Gateway
3. Test API Gateway integration
4. Debug integration issues
```

## Fix and Redeploy

**Prompt**:
```
I've identified and fixed the issue in my Lambda function.

Changes made:
[Describe changes]

Please provide:
1. Commands to rebuild and redeploy (sam build && sam deploy)
2. How to verify the fix worked
3. How to test the updated function
4. What to check in CloudWatch Logs after redeployment
```

## Prevention Best Practices

**Prompt**:
```
I want to add better error handling and logging to prevent future issues.

Please show me:
1. How to add comprehensive try/catch blocks
2. Best practices for console.log() statements
3. How to log request/response for debugging
4. Error handling patterns for Lambda functions
5. Input validation techniques
```

## Emergency Rollback

**Prompt**:
```
My latest deployment broke the application and I need to rollback quickly.

Stack name: techmoda-capstone

Please help:
1. How to rollback to previous version
2. AWS CLI commands to revert stack
3. How to identify previous working version
4. Steps to quickly restore service
```

## Next Steps

After debugging and fixing issues:

1. Redeploy with fixes
2. Verify all tests pass
3. Document issues and solutions
4. Add preventive measures (better error handling, logging)
5. Proceed to [Operations Prompts](06_OPERATIONS.md)
