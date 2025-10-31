# TechModa Serverless Capstone

Fashion E-commerce Product Catalog API built with AWS Serverless Technologies

## Overview

TechModa is a serverless REST API for managing a fashion e-commerce product catalog. This capstone project demonstrates mastery of AWS serverless architecture patterns using Lambda, API Gateway, and DynamoDB.

### Learning Objectives

By completing this project, you will:

- Design serverless architectures using Lambda, API Gateway, and DynamoDB
- Implement RESTful APIs with proper HTTP methods and status codes
- Deploy infrastructure as code using AWS SAM
- Test APIs manually using curl and interpret responses
- Debug serverless applications using CloudWatch Logs and X-Ray
- Estimate and manage AWS costs for serverless applications
- Use AI tools effectively (Claude Code) to accelerate development
- Document technical projects for portfolio purposes
- Follow AWS best practices for security and observability

## Architecture

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   Client    │─────▶│ API Gateway │─────▶│   Lambda    │─────▶│  DynamoDB   │
│  (curl/     │◀─────│   (REST)    │◀─────│ (Node.js)   │◀─────│   (NoSQL)   │
│  browser)   │      └─────────────┘      └─────────────┘      └─────────────┘
└─────────────┘              │                     │
                             │                     │
                             ▼                     ▼
                      ┌─────────────┐      ┌─────────────┐
                      │  CloudWatch │      │   X-Ray     │
                      │    Logs     │      │   Tracing   │
                      └─────────────┘      └─────────────┘
```

### Components

- **API Gateway**: REST API with 5 endpoints for CRUD operations
- **Lambda Functions**: 5 Node.js 18.x functions (ListItems, CreateItem, GetItem, UpdateItem, DeleteItem)
- **DynamoDB**: NoSQL database with PAY_PER_REQUEST billing
- **CloudWatch**: Centralized logging for Lambda execution
- **X-Ray**: Distributed tracing for performance observability

For detailed architecture documentation, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## Prerequisites

Before starting, ensure you have:

- **AWS Account** with appropriate permissions
- **AWS CLI v2** installed and configured ([Installation Guide](docs/prompts/01_ENVIRONMENT_SETUP.md))
- **AWS SAM CLI** installed ([Installation Guide](docs/prompts/01_ENVIRONMENT_SETUP.md))
- **Node.js 18.x** or later
- **Git** for version control
- **Basic knowledge** of JavaScript, REST APIs, and AWS services

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd techmoda-serverless-capstone-starter
```

### 2. Review the Project Structure

```
techmoda-serverless-capstone-starter/
├── template.yaml              # SAM template (infrastructure as code)
├── functions/                 # Lambda function source code
│   ├── list-items/           # GET /products
│   ├── create-item/          # POST /products
│   ├── get-item/             # GET /products/{id}
│   ├── update-item/          # PUT /products/{id}
│   └── delete-item/          # DELETE /products/{id}
├── docs/                      # Documentation
│   ├── specs/                # Detailed function specifications
│   └── prompts/              # Claude Code prompt templates
├── scripts/                   # Deployment helper scripts
│   ├── build.sh              # Build the SAM application
│   ├── deploy.sh             # Deploy to AWS
│   └── delete.sh             # Clean up resources
└── README.md                  # This file
```

### 3. Implement Lambda Functions

Each Lambda function in the `functions/` directory contains placeholder code with TODO comments. Follow these steps:

1. **Read the specification** for each function in `docs/specs/`
2. **Use the prompt templates** in `docs/prompts/02_LAMBDA_IMPLEMENTATION.md` with Claude Code
3. **Implement the business logic** following the spec-driven development approach
4. **Test locally** (optional) or deploy and test in AWS

See [CAPSTONE_OVERVIEW.md](CAPSTONE_OVERVIEW.md) for detailed implementation guidance.

### 4. Build the Application

```bash
# Using the helper script
./scripts/build.sh

# Or directly with SAM CLI
sam build
```

This command:
- Installs Node.js dependencies for each function
- Prepares the deployment package
- Creates `.aws-sam/build/` directory

### 5. Deploy to AWS

#### First Deployment (Guided)

```bash
# Using the helper script
./scripts/deploy.sh

# Or directly with SAM CLI
sam deploy --guided
```

Follow the prompts:
- **Stack Name**: `techmoda-capstone` (or your preferred name)
- **AWS Region**: `us-east-1` (or your preferred region)
- **Confirm changes**: Yes
- **Allow SAM CLI IAM role creation**: Yes
- **Disable rollback**: No
- **Save arguments to configuration**: Yes

#### Subsequent Deployments

```bash
# Using the helper script
./scripts/deploy.sh

# Or directly with SAM CLI
sam deploy
```

### 6. Test Your API

After deployment, you'll receive an API URL in the outputs:

```
Outputs:
  ApiUrl: https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/Prod
```

Copy this URL and test your endpoints using curl. See [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md) for complete testing instructions.

**Quick test example:**

```bash
# Set your API URL
export API_URL="https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com/Prod"

# Create a product
curl -X POST $API_URL/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Classic Denim Jacket",
    "description": "Timeless blue denim jacket",
    "price": 79.99,
    "category": "Outerwear",
    "imageUrl": "https://example.com/jacket.jpg"
  }'

# List all products
curl $API_URL/products
```

### 7. Clean Up Resources

**IMPORTANT**: To avoid AWS charges, delete your stack after testing:

```bash
# Using the helper script
./scripts/delete.sh

# Or directly with SAM CLI
sam delete --stack-name techmoda-capstone
```

See [docs/COST_AND_CLEANUP.md](docs/COST_AND_CLEANUP.md) for cost estimates and cleanup best practices.

## Documentation

### Core Documentation
- [CAPSTONE_OVERVIEW.md](CAPSTONE_OVERVIEW.md) - Project description and submission requirements
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - Detailed architecture and component descriptions
- [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md) - Complete testing instructions with curl examples
- [docs/COST_AND_CLEANUP.md](docs/COST_AND_CLEANUP.md) - Cost estimation and cleanup procedures

### Lambda Function Specifications
- [docs/specs/LIST_ITEMS_SPEC.md](docs/specs/LIST_ITEMS_SPEC.md) - List all products
- [docs/specs/CREATE_ITEM_SPEC.md](docs/specs/CREATE_ITEM_SPEC.md) - Create a new product
- [docs/specs/GET_ITEM_SPEC.md](docs/specs/GET_ITEM_SPEC.md) - Get a product by ID
- [docs/specs/UPDATE_ITEM_SPEC.md](docs/specs/UPDATE_ITEM_SPEC.md) - Update an existing product
- [docs/specs/DELETE_ITEM_SPEC.md](docs/specs/DELETE_ITEM_SPEC.md) - Delete a product

### Prompt Templates (For Claude Code)
- [docs/prompts/01_ENVIRONMENT_SETUP.md](docs/prompts/01_ENVIRONMENT_SETUP.md) - AWS CLI and SAM installation
- [docs/prompts/02_LAMBDA_IMPLEMENTATION.md](docs/prompts/02_LAMBDA_IMPLEMENTATION.md) - Lambda function implementations
- [docs/prompts/03_DEPLOYMENT.md](docs/prompts/03_DEPLOYMENT.md) - Build and deployment
- [docs/prompts/04_TESTING.md](docs/prompts/04_TESTING.md) - API testing with curl
- [docs/prompts/05_DEBUGGING.md](docs/prompts/05_DEBUGGING.md) - Troubleshooting common issues
- [docs/prompts/06_OPERATIONS.md](docs/prompts/06_OPERATIONS.md) - Cost estimation and cleanup

## Troubleshooting

### Common Issues

**Build Failures**
- Ensure Node.js 18.x is installed: `node --version`
- Check that package.json exists in each function directory
- Delete `.aws-sam` folder and rebuild: `rm -rf .aws-sam && sam build`

**Deployment Failures**
- Verify AWS credentials: `aws sts get-caller-identity`
- Check IAM permissions for CloudFormation, Lambda, API Gateway, DynamoDB
- Review CloudFormation events in AWS Console for specific errors

**API Errors (404, 500)**
- Check CloudWatch Logs for Lambda function errors
- Verify environment variable `PRODUCTS_TABLE` is set correctly
- Ensure DynamoDB table exists: `aws dynamodb list-tables`
- Review X-Ray traces in AWS Console

**Permission Errors**
- Verify SAM template IAM policies match function requirements
- Check Lambda execution role has DynamoDB permissions
- Ensure CloudFormation has CAPABILITY_IAM

For detailed debugging guidance, see [docs/prompts/05_DEBUGGING.md](docs/prompts/05_DEBUGGING.md)

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | /products | List all products |
| POST | /products | Create a new product |
| GET | /products/{id} | Get a product by ID |
| PUT | /products/{id} | Update an existing product |
| DELETE | /products/{id} | Delete a product |

## Data Schema

### Product Object

```json
{
  "productId": "string (UUID)",
  "name": "string (required)",
  "description": "string",
  "price": "number (required)",
  "category": "string",
  "imageUrl": "string (URL)",
  "createdAt": "string (ISO 8601 timestamp)",
  "updatedAt": "string (ISO 8601 timestamp)"
}
```

## Submission Requirements

For this capstone project, submit:

1. **GitHub Repository URL** with:
   - Complete SAM template (template.yaml)
   - All 5 Lambda functions implemented
   - README with architecture diagram and deployment instructions
   - Working curl test examples

2. **Architecture Diagram** (in README or separate file)

3. **Evidence of Working Implementation** (optional screenshots or curl output)

See [CAPSTONE_OVERVIEW.md](CAPSTONE_OVERVIEW.md) for complete submission and evaluation criteria.

## Cost Estimation

Expected AWS costs for this capstone project: **Under $1 USD**

This assumes:
- Development and testing over 1-2 days
- Approximately 50-100 API requests
- All services within AWS Free Tier limits

**IMPORTANT**: Delete your stack immediately after testing to avoid ongoing charges.

For detailed cost breakdown, see [docs/COST_AND_CLEANUP.md](docs/COST_AND_CLEANUP.md)

## Resources

- [AWS SAM Documentation](https://docs.aws.amazon.com/serverless-application-model/)
- [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/)
- [DynamoDB Developer Guide](https://docs.aws.amazon.com/dynamodb/)
- [API Gateway REST API Documentation](https://docs.aws.amazon.com/apigateway/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions or issues:
1. Review the documentation in `docs/`
2. Check the prompt templates in `docs/prompts/`
3. Consult your bootcamp instructor
4. Review CloudWatch Logs for error details

---

**Good luck with your capstone project!** 🚀
