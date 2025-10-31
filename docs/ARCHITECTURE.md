# TechModa Serverless Architecture

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Internet/Client                             │
│                       (curl, Postman, Browser)                       │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
                             │ HTTPS Requests
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     Amazon API Gateway (REST API)                    │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  Endpoints:                                                     │ │
│  │  • GET  /products          → ListItems Lambda                  │ │
│  │  • POST /products          → CreateItem Lambda                 │ │
│  │  • GET  /products/{id}     → GetItem Lambda                    │ │
│  │  • PUT  /products/{id}     → UpdateItem Lambda                 │ │
│  │  • DELETE /products/{id}   → DeleteItem Lambda                 │ │
│  └────────────────────────────────────────────────────────────────┘ │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
                             │ Event Invocation
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
┌───────────────────────────┐   ┌──────────────────────────┐
│   AWS Lambda Functions    │   │   CloudWatch & X-Ray     │
│  ┌─────────────────────┐  │   │                          │
│  │  ListItems          │──┼───│→ Logs & Traces           │
│  │  (GET /products)    │  │   │                          │
│  └─────────────────────┘  │   └──────────────────────────┘
│  ┌─────────────────────┐  │
│  │  CreateItem         │  │
│  │  (POST /products)   │  │
│  └─────────────────────┘  │
│  ┌─────────────────────┐  │
│  │  GetItem            │  │
│  │  (GET /products/id) │  │
│  └─────────────────────┘  │
│  ┌─────────────────────┐  │
│  │  UpdateItem         │  │
│  │  (PUT /products/id) │  │
│  └─────────────────────┘  │
│  ┌─────────────────────┐  │
│  │  DeleteItem         │  │
│  │  (DELETE /prod.../id)│ │
│  └─────────────────────┘  │
└────────────┬──────────────┘
             │
             │ DynamoDB SDK v3 Operations
             │ (Scan, PutItem, GetItem, UpdateItem, DeleteItem)
             │
             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        Amazon DynamoDB                               │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  Table: TechModa-Products                                      │ │
│  │  Primary Key: productId (String)                               │ │
│  │  Billing Mode: PAY_PER_REQUEST                                 │ │
│  │                                                                 │ │
│  │  Attributes:                                                    │ │
│  │  • productId (String) - UUID                                   │ │
│  │  • name (String)                                               │ │
│  │  • description (String)                                        │ │
│  │  • price (Number)                                              │ │
│  │  • category (String)                                           │ │
│  │  • imageUrl (String)                                           │ │
│  │  • createdAt (String) - ISO 8601                               │ │
│  │  • updatedAt (String) - ISO 8601                               │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## Component Descriptions

### Amazon API Gateway

**Purpose**: Serves as the entry point for all HTTP requests to the product catalog API.

**Configuration**:
- **Type**: REST API (not HTTP API)
- **Stage**: Prod
- **Endpoint Type**: Regional
- **CORS**: Enabled for all endpoints
- **Integration**: Lambda Proxy Integration (passes entire request to Lambda)

**Responsibilities**:
- Route requests to appropriate Lambda functions based on HTTP method and path
- Handle CORS preflight requests
- Return Lambda responses to clients with proper HTTP status codes
- Log requests to CloudWatch

**Base URL Format**: `https://{api-id}.execute-api.us-east-1.amazonaws.com/Prod`

### AWS Lambda Functions

**Purpose**: Execute business logic for each CRUD operation.

**Common Configuration (all 5 functions)**:
- **Runtime**: Node.js 18.x
- **Memory**: 1024 MB
- **Timeout**: 30 seconds
- **Architecture**: x86_64
- **X-Ray Tracing**: Active
- **Environment Variables**: `PRODUCTS_TABLE` (injected by SAM)

**IAM Permissions**:
Each function has least-privilege access to DynamoDB:
- ListItems: `dynamodb:Scan`
- CreateItem: `dynamodb:PutItem`
- GetItem: `dynamodb:GetItem`
- UpdateItem: `dynamodb:GetItem`, `dynamodb:UpdateItem`
- DeleteItem: `dynamodb:DeleteItem`

### Amazon DynamoDB

**Purpose**: Persistent NoSQL data store for product catalog.

**Table Configuration**:
- **Table Name**: `{StackName}-Products` (e.g., `techmoda-capstone-Products`)
- **Primary Key**: `productId` (String) - Partition key only
- **Billing Mode**: PAY_PER_REQUEST (on-demand)
- **Deletion Protection**: Disabled (for easy cleanup)

**Schema Design**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| productId | String | Yes | UUID v4 generated by CreateItem |
| name | String | Yes | Product name (e.g., "Classic Denim Jacket") |
| description | String | No | Product description |
| price | Number | Yes | Price in USD (e.g., 79.99) |
| category | String | No | Fashion category (e.g., "Jackets") |
| imageUrl | String | No | URL to product image |
| createdAt | String | Yes | ISO 8601 timestamp of creation |
| updatedAt | String | Yes | ISO 8601 timestamp of last update |

**Why PAY_PER_REQUEST?**
- No capacity planning needed (no RCU/WCU to configure)
- Cost-effective for low-volume applications
- Automatically scales with traffic
- Ideal for student projects and prototypes

### CloudWatch Logs

**Purpose**: Centralized logging for Lambda function execution.

**Log Groups**:
Each Lambda function automatically creates a log group:
- `/aws/lambda/{StackName}-ListItems`
- `/aws/lambda/{StackName}-CreateItem`
- `/aws/lambda/{StackName}-GetItem`
- `/aws/lambda/{StackName}-UpdateItem`
- `/aws/lambda/{StackName}-DeleteItem`

**What Gets Logged**:
- Function invocation start/end
- Console.log() statements from code
- Errors and stack traces
- Lambda runtime errors
- DynamoDB operation results

**Retention**: 7 days (configurable in SAM template)

### AWS X-Ray

**Purpose**: Distributed tracing for request flow visualization.

**Configuration**:
- Enabled for API Gateway
- Enabled for all Lambda functions (via `Tracing: Active`)
- Automatic instrumentation of AWS SDK calls

**Trace Details**:
- API Gateway → Lambda invocation latency
- Lambda execution time breakdown
- DynamoDB operation duration
- Error identification
- Cold start vs. warm start analysis

### IAM Roles

**Purpose**: Secure access control following least-privilege principle.

**Lambda Execution Roles**:
SAM automatically creates execution roles for each function with:
- `AWSLambdaBasicExecutionRole` (CloudWatch Logs write)
- `AWSXRayDaemonWriteAccess` (X-Ray tracing)
- Custom DynamoDB policies (specific to function needs)

**Example Policy (ListItems)**:
```yaml
Policies:
  - DynamoDBReadPolicy:
      TableName: !Ref ProductsTable
```

This grants only `dynamodb:Scan` and `dynamodb:GetItem` on the specific table.

## Data Flow Diagrams

### Create Product Flow

```
1. Client sends POST request
   └─> curl -X POST {API_URL}/products -H "Content-Type: application/json" -d '{...}'

2. API Gateway receives request
   └─> Validates HTTP method, headers
   └─> Routes to CreateItem Lambda

3. CreateItem Lambda processes
   └─> Parses JSON body (JSON.parse(event.body))
   └─> Validates required fields (name, price)
   └─> Generates UUID (crypto.randomUUID())
   └─> Adds timestamps (new Date().toISOString())
   └─> Calls DynamoDB PutItem
   └─> Returns 201 Created with product object

4. DynamoDB stores item
   └─> Writes to TechModa-Products table
   └─> Returns success

5. API Gateway sends response
   └─> HTTP 201 with JSON body
   └─> Includes CORS headers
```

### List Products Flow

```
1. Client sends GET request
   └─> curl -X GET {API_URL}/products

2. API Gateway receives request
   └─> Routes to ListItems Lambda

3. ListItems Lambda processes
   └─> Calls DynamoDB Scan (no filters)
   └─> Receives all items
   └─> Returns 200 OK with products array

4. DynamoDB returns items
   └─> Scans entire table
   └─> Returns Items array

5. API Gateway sends response
   └─> HTTP 200 with JSON array
```

### Get Product Flow

```
1. Client sends GET request with ID
   └─> curl -X GET {API_URL}/products/{productId}

2. API Gateway receives request
   └─> Extracts path parameter {id}
   └─> Routes to GetItem Lambda

3. GetItem Lambda processes
   └─> Extracts productId from event.pathParameters.id
   └─> Calls DynamoDB GetItem with Key: {productId}
   └─> If found: return 200 with product
   └─> If not found: return 404

4. DynamoDB retrieves item
   └─> Direct key lookup (fast)
   └─> Returns Item or null

5. API Gateway sends response
   └─> HTTP 200 (found) or 404 (not found)
```

### Update Product Flow

```
1. Client sends PUT request with ID and body
   └─> curl -X PUT {API_URL}/products/{productId} -H "Content-Type: application/json" -d '{...}'

2. API Gateway receives request
   └─> Extracts path parameter {id}
   └─> Routes to UpdateItem Lambda

3. UpdateItem Lambda processes
   └─> Extracts productId from path parameters
   └─> Parses update fields from body
   └─> Calls DynamoDB GetItem (check existence)
   └─> If not exists: return 404
   └─> Updates timestamp (updatedAt)
   └─> Calls DynamoDB UpdateItem
   └─> Returns 200 with updated product

4. DynamoDB updates item
   └─> Modifies specified attributes
   └─> Returns updated item

5. API Gateway sends response
   └─> HTTP 200 (updated) or 404 (not found)
```

### Delete Product Flow

```
1. Client sends DELETE request with ID
   └─> curl -X DELETE {API_URL}/products/{productId}

2. API Gateway receives request
   └─> Extracts path parameter {id}
   └─> Routes to DeleteItem Lambda

3. DeleteItem Lambda processes
   └─> Extracts productId from path parameters
   └─> Calls DynamoDB DeleteItem
   └─> Returns 200 with success message

4. DynamoDB deletes item
   └─> Removes item by primary key
   └─> Succeeds even if item doesn't exist (idempotent)

5. API Gateway sends response
   └─> HTTP 200 with deletion confirmation
```

## API Endpoint Specifications

### Base URL

```
https://{api-id}.execute-api.us-east-1.amazonaws.com/Prod
```

Replace `{api-id}` with your actual API Gateway ID from deployment output.

### Endpoints Summary

| Method | Endpoint | Function | Purpose |
|--------|----------|----------|---------|
| GET | /products | ListItems | List all products |
| POST | /products | CreateItem | Create new product |
| GET | /products/{id} | GetItem | Get product by ID |
| PUT | /products/{id} | UpdateItem | Update product |
| DELETE | /products/{id} | DeleteItem | Delete product |

### 1. List Products

**Endpoint**: `GET /products`

**Request**:
- No path parameters
- No query parameters
- No request body

**Success Response (200 OK)**:
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
      "createdAt": "2025-10-30T12:00:00Z",
      "updatedAt": "2025-10-30T12:00:00Z"
    }
  ]
}
```

**Error Response (500 Internal Server Error)**:
```json
{
  "error": "Internal server error",
  "message": "Failed to retrieve products"
}
```

### 2. Create Product

**Endpoint**: `POST /products`

**Request Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "name": "Classic Denim Jacket",
  "description": "Timeless denim jacket for all seasons",
  "price": 79.99,
  "category": "Jackets",
  "imageUrl": "https://example.com/jacket.jpg"
}
```

**Required Fields**: `name`, `price`

**Success Response (201 Created)**:
```json
{
  "productId": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Classic Denim Jacket",
  "description": "Timeless denim jacket for all seasons",
  "price": 79.99,
  "category": "Jackets",
  "imageUrl": "https://example.com/jacket.jpg",
  "createdAt": "2025-10-30T12:00:00Z",
  "updatedAt": "2025-10-30T12:00:00Z"
}
```

**Error Responses**:

400 Bad Request (missing required fields):
```json
{
  "error": "Bad Request",
  "message": "Missing required field: name"
}
```

500 Internal Server Error:
```json
{
  "error": "Internal server error",
  "message": "Failed to create product"
}
```

### 3. Get Product

**Endpoint**: `GET /products/{id}`

**Path Parameters**:
- `id`: Product UUID (productId)

**Success Response (200 OK)**:
```json
{
  "productId": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Classic Denim Jacket",
  "description": "Timeless denim jacket for all seasons",
  "price": 79.99,
  "category": "Jackets",
  "imageUrl": "https://example.com/jacket.jpg",
  "createdAt": "2025-10-30T12:00:00Z",
  "updatedAt": "2025-10-30T12:00:00Z"
}
```

**Error Responses**:

404 Not Found:
```json
{
  "error": "Not Found",
  "message": "Product not found"
}
```

500 Internal Server Error:
```json
{
  "error": "Internal server error",
  "message": "Failed to retrieve product"
}
```

### 4. Update Product

**Endpoint**: `PUT /products/{id}`

**Path Parameters**:
- `id`: Product UUID (productId)

**Request Headers**:
```
Content-Type: application/json
```

**Request Body** (partial update):
```json
{
  "price": 69.99,
  "description": "Updated description with sale pricing"
}
```

**Success Response (200 OK)**:
```json
{
  "productId": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Classic Denim Jacket",
  "description": "Updated description with sale pricing",
  "price": 69.99,
  "category": "Jackets",
  "imageUrl": "https://example.com/jacket.jpg",
  "createdAt": "2025-10-30T12:00:00Z",
  "updatedAt": "2025-10-30T14:30:00Z"
}
```

**Error Responses**:

404 Not Found:
```json
{
  "error": "Not Found",
  "message": "Product not found"
}
```

400 Bad Request:
```json
{
  "error": "Bad Request",
  "message": "Invalid update data"
}
```

500 Internal Server Error:
```json
{
  "error": "Internal server error",
  "message": "Failed to update product"
}
```

### 5. Delete Product

**Endpoint**: `DELETE /products/{id}`

**Path Parameters**:
- `id`: Product UUID (productId)

**Success Response (200 OK)**:
```json
{
  "message": "Product deleted successfully",
  "productId": "123e4567-e89b-12d3-a456-426614174000"
}
```

**Error Responses**:

404 Not Found (if existence check implemented):
```json
{
  "error": "Not Found",
  "message": "Product not found"
}
```

500 Internal Server Error:
```json
{
  "error": "Internal server error",
  "message": "Failed to delete product"
}
```

## DynamoDB Operations

### Scan (ListItems)

**Operation**: Retrieves all items from table

**Code Example**:
```javascript
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const result = await docClient.send(new ScanCommand({
  TableName: process.env.PRODUCTS_TABLE
}));

const products = result.Items;
```

**Performance Note**: Scan reads entire table, not suitable for large datasets. Acceptable for capstone scope.

### PutItem (CreateItem)

**Operation**: Creates new item in table

**Code Example**:
```javascript
const { PutCommand } = require('@aws-sdk/lib-dynamodb');

const product = {
  productId: crypto.randomUUID(),
  name: 'Classic Denim Jacket',
  price: 79.99,
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString()
};

await docClient.send(new PutCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Item: product
}));
```

### GetItem (GetItem)

**Operation**: Retrieves single item by primary key

**Code Example**:
```javascript
const { GetCommand } = require('@aws-sdk/lib-dynamodb');

const result = await docClient.send(new GetCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: {
    productId: 'uuid-here'
  }
}));

const product = result.Item; // null if not found
```

### UpdateItem (UpdateItem)

**Operation**: Modifies existing item attributes

**Code Example**:
```javascript
const { UpdateCommand } = require('@aws-sdk/lib-dynamodb');

const result = await docClient.send(new UpdateCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: {
    productId: 'uuid-here'
  },
  UpdateExpression: 'SET price = :price, updatedAt = :updatedAt',
  ExpressionAttributeValues: {
    ':price': 69.99,
    ':updatedAt': new Date().toISOString()
  },
  ReturnValues: 'ALL_NEW'
}));

const updatedProduct = result.Attributes;
```

### DeleteItem (DeleteItem)

**Operation**: Removes item from table

**Code Example**:
```javascript
const { DeleteCommand } = require('@aws-sdk/lib-dynamodb');

await docClient.send(new DeleteCommand({
  TableName: process.env.PRODUCTS_TABLE,
  Key: {
    productId: 'uuid-here'
  }
}));
```

**Note**: DeleteItem succeeds even if item doesn't exist (idempotent operation).

## Observability

### CloudWatch Logs Analysis

**How to View Logs**:
1. AWS Console → CloudWatch → Log groups
2. Select `/aws/lambda/{StackName}-{FunctionName}`
3. View log streams (one per Lambda execution)

**What to Look For**:
- START/END/REPORT lines (Lambda runtime info)
- Console.log() output from your code
- ERROR messages with stack traces
- Duration and memory usage statistics

**Example Log Entry**:
```
START RequestId: abc-123 Version: $LATEST
2025-10-30T12:00:00.000Z  abc-123  INFO  Received event: {...}
2025-10-30T12:00:00.100Z  abc-123  ERROR  DynamoDB error: AccessDeniedException
END RequestId: abc-123
REPORT RequestId: abc-123  Duration: 150.00 ms  Billed Duration: 150 ms  Memory Size: 1024 MB  Max Memory Used: 85 MB
```

### X-Ray Traces

**How to View Traces**:
1. AWS Console → X-Ray → Traces
2. Filter by time range (last 5 minutes)
3. Click individual trace to see details

**Service Map**:
Shows visual representation of:
- API Gateway → Lambda → DynamoDB call chain
- Latency for each segment
- Error rates
- Cold start indicators

**Trace Details**:
- Total request duration
- Time spent in each service
- DynamoDB query performance
- Error locations

## Security Considerations

### IAM Least-Privilege

Each Lambda function has only the permissions it needs:
- No wildcard resource ARNs (`*`)
- No admin access
- Table-specific policies
- Operation-specific permissions

### CORS Configuration

API Gateway allows cross-origin requests for browser compatibility:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Headers: Content-Type`
- `Access-Control-Allow-Methods: GET,POST,PUT,DELETE,OPTIONS`

**Production Note**: In real applications, restrict `Allow-Origin` to specific domains.

### API Authentication

**Not Implemented** (out of capstone scope):
- No API keys
- No AWS Signature Version 4
- No Cognito user pools
- Public API for demonstration purposes

**Production Requirement**: Always add authentication to production APIs.

## Performance Characteristics

### Expected Latency

| Operation | Cold Start | Warm Start |
|-----------|------------|------------|
| List Products | 800-1200ms | 100-200ms |
| Create Product | 800-1200ms | 150-250ms |
| Get Product | 800-1200ms | 50-100ms |
| Update Product | 800-1200ms | 150-250ms |
| Delete Product | 800-1200ms | 100-150ms |

**Cold Start**: First invocation after deployment or idle period
**Warm Start**: Subsequent invocations within ~15 minutes

### Scalability

- **Lambda**: Automatic scaling up to account concurrency limit (default 1000)
- **API Gateway**: Handles 10,000 requests per second by default
- **DynamoDB**: PAY_PER_REQUEST mode automatically scales to handle traffic

### Throughput Limits

For student capstone projects, these limits are not concerns:
- Lambda: 1000 concurrent executions
- API Gateway: 10,000 RPS per region
- DynamoDB: No throughput limits in PAY_PER_REQUEST mode

## Architecture Decisions

### Why Serverless?

✅ **Cost-effective**: Pay only for actual usage
✅ **No server management**: AWS handles scaling, patching, availability
✅ **Fast deployment**: Deploy changes in minutes
✅ **Auto-scaling**: Handles traffic spikes automatically
✅ **Portfolio value**: Modern, in-demand architecture pattern

### Why Node.js?

✅ **JavaScript familiarity**: Most accessible language for bootcamp students
✅ **AWS SDK v3**: First-class support for DynamoDB
✅ **Fast cold starts**: Lighter runtime than Java or .NET
✅ **JSON native**: Natural fit for REST API development

### Why DynamoDB?

✅ **Fully managed**: No database administration
✅ **Serverless integration**: Built for Lambda use cases
✅ **PAY_PER_REQUEST**: No capacity planning needed
✅ **Single-table design**: Simple schema for capstone scope

### Why SAM over Serverless Framework?

✅ **AWS native**: Official AWS tooling
✅ **CloudFormation integration**: Same syntax as IaC standard
✅ **Free tier**: No external service costs
✅ **Local testing**: `sam local` commands for development

## Next Steps

1. Review [Lambda Function Specifications](specs/) for implementation details
2. Study [Testing Guide](TESTING_GUIDE.md) for curl examples
3. Check [Cost and Cleanup](COST_AND_CLEANUP.md) for AWS pricing details
4. Use [Prompt Templates](prompts/) for AI-assisted development
