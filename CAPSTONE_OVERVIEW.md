# TechModa Serverless Capstone - Overview

## Project Description

The TechModa Serverless Capstone is a hands-on project where you'll build a production-ready REST API for a fashion e-commerce product catalog using AWS serverless technologies. This project serves as the culmination of your AWS Serverless Architecture bootcamp, demonstrating your ability to design, implement, deploy, and operate serverless applications.

### Business Context

**TechModa** is a fashion e-commerce platform that needs a scalable, cost-effective product catalog management system. Your task is to build a serverless REST API that enables:

- Listing all fashion products in the catalog
- Adding new products (dresses, jackets, accessories, etc.)
- Retrieving individual product details
- Updating product information (prices, descriptions, inventory)
- Removing discontinued products

This architecture must be:
- **Scalable**: Handle varying traffic without manual intervention
- **Cost-effective**: Pay only for actual usage (no idle server costs)
- **Reliable**: Built on AWS managed services with high availability
- **Observable**: Provide logging and tracing for troubleshooting

## Learning Objectives

By completing this capstone project, you will demonstrate mastery of:

1. **Serverless Architecture Design**
   - Design event-driven systems using Lambda, API Gateway, and DynamoDB
   - Understand when to use serverless vs. traditional architectures
   - Apply the AWS Well-Architected Framework principles

2. **RESTful API Implementation**
   - Implement proper HTTP methods (GET, POST, PUT, DELETE)
   - Return appropriate status codes (200, 201, 404, 500)
   - Structure JSON request/response payloads
   - Handle CORS for web client compatibility

3. **Infrastructure as Code (IaC)**
   - Write AWS SAM templates for serverless applications
   - Define resources declaratively (Lambda, API Gateway, DynamoDB)
   - Manage IAM roles and permissions with least-privilege principle
   - Version control infrastructure alongside application code

4. **Manual API Testing**
   - Test endpoints using curl commands
   - Interpret HTTP responses and troubleshoot failures
   - Verify CRUD operations work correctly
   - Validate error handling scenarios

5. **Serverless Application Debugging**
   - Analyze CloudWatch Logs for Lambda execution errors
   - Interpret X-Ray traces for performance insights
   - Diagnose permission issues (IAM roles, DynamoDB access)
   - Troubleshoot API Gateway configuration problems

6. **AWS Cost Management**
   - Estimate costs for serverless workloads
   - Understand AWS Free Tier limits
   - Use PAY_PER_REQUEST billing for DynamoDB
   - Clean up resources to prevent unnecessary charges

7. **AI-Accelerated Development**
   - Use Claude Code to generate Lambda function implementations
   - Write effective prompts for code generation
   - Debug with AI assistance
   - Accelerate development while maintaining code quality

8. **Technical Documentation**
   - Create architecture diagrams
   - Write clear deployment instructions
   - Document API endpoints with examples
   - Produce portfolio-quality GitHub repositories

9. **AWS Best Practices**
   - Follow security best practices (IAM least-privilege)
   - Enable observability (CloudWatch Logs, X-Ray tracing)
   - Use managed services to reduce operational overhead
   - Design for cost optimization

## Technology Stack

### AWS Services

| Service | Purpose | Configuration |
|---------|---------|---------------|
| **AWS Lambda** | Compute layer for business logic | Node.js 18.x runtime, 1024 MB memory, 30s timeout |
| **API Gateway** | REST API frontend | Regional endpoint, CORS enabled, Prod stage |
| **DynamoDB** | NoSQL database | PAY_PER_REQUEST billing, single table design |
| **CloudWatch** | Centralized logging | Automatic log groups for each Lambda function |
| **X-Ray** | Distributed tracing | Enabled for API Gateway and all Lambda functions |
| **IAM** | Security and permissions | Least-privilege roles managed by SAM |
| **CloudFormation** | Infrastructure deployment | Via AWS SAM abstraction |

### Development Tools

- **AWS SAM CLI**: Build and deploy serverless applications
- **AWS CLI v2**: Interact with AWS services from command line
- **Node.js 18.x**: Lambda runtime and local development
- **Git**: Version control for code and infrastructure
- **Claude Code**: AI-assisted development and debugging
- **curl**: Manual API testing

### Programming

- **Language**: JavaScript (Node.js 18.x)
- **AWS SDK**: @aws-sdk/client-dynamodb and @aws-sdk/lib-dynamodb (v3)
- **Response Format**: JSON with proper HTTP headers
- **Error Handling**: Try/catch blocks with graceful error responses

## Architecture Overview

```
Internet
   │
   ▼
┌──────────────────────────────────────────────────────────────┐
│  API Gateway (REST API)                                       │
│  - /products (GET, POST)                                      │
│  - /products/{id} (GET, PUT, DELETE)                          │
└───────────────┬──────────────────────────────────────────────┘
                │
        ┌───────┴───────┐
        │   Lambda      │
        │  Invocations  │
        └───────┬───────┘
                │
    ┌───────────┴───────────┐
    │                       │
┌───▼───┐  ┌───▼───┐   ┌───▼───┐  ┌───▼───┐   ┌───▼───┐
│ List  │  │Create │   │  Get  │  │Update │   │Delete │
│ Items │  │ Item  │   │ Item  │  │ Item  │   │ Item  │
└───┬───┘  └───┬───┘   └───┬───┘  └───┬───┘   └───┬───┘
    │          │           │          │           │
    └──────────┴───────────┴──────────┴───────────┘
                           │
                           ▼
                  ┌────────────────┐
                  │   DynamoDB     │
                  │ Products Table │
                  └────────────────┘
```

For detailed architecture documentation, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Submission Requirements

### Required Deliverables

To complete this capstone, you must submit:

1. **GitHub Repository URL** containing:
   - Complete and working SAM template (template.yaml)
   - All 5 Lambda functions fully implemented
   - README.md with architecture diagram and deployment instructions
   - Documentation of curl test examples

### Repository Must Include

✅ **template.yaml** - Valid SAM template with all resources
✅ **functions/** - All 5 Lambda functions with working implementations
✅ **README.md** - Project overview, architecture diagram, deployment steps
✅ **Curl test examples** - Documented in README or separate test guide
✅ **Clean git history** - Meaningful commit messages

### Optional (Recommended)

- Screenshots of successful API tests
- Architecture diagram generated with diagrams.py or draw.io
- Evidence of using Claude Code (prompts used, commit messages)
- Cost estimation calculations
- X-Ray trace screenshots

### Submission Deadline

See your bootcamp instructor for the specific deadline. Typically:
- **In-class time**: Session 10 (2 hours)
- **Homework time**: Additional 2-4 hours
- **Final submission**: End of Session 10 evaluation period

## Evaluation Rubric

Your capstone will be evaluated across three dimensions totaling **60% of your overall bootcamp grade**.

### Technical Excellence (30%)

| Criterion | Points | Description |
|-----------|--------|-------------|
| All 5 CRUD operations functional | 10% | List, Create, Get, Update, Delete all work correctly |
| Proper error handling | 5% | Try/catch blocks, appropriate status codes (404, 500) |
| Code quality and readability | 5% | Clean code, comments, consistent formatting |
| SAM template correctness | 5% | Valid YAML, all resources defined, deployable |
| AWS best practices | 5% | IAM least-privilege, X-Ray enabled, environment variables |

### Documentation (15%)

| Criterion | Points | Description |
|-----------|--------|-------------|
| README completeness | 5% | Overview, architecture, deployment steps, testing examples |
| Architecture diagram | 5% | Clear visual representation of system components |
| Testing examples | 5% | Documented curl commands for all endpoints |

### Business Relevance (15%)

| Criterion | Points | Description |
|-----------|--------|-------------|
| Solves fashion catalog problem | 7% | Implements product catalog management appropriately |
| Appropriate technology choices | 5% | Uses serverless architecture effectively |
| Cost-consciousness | 3% | Demonstrates understanding of AWS pricing, cleanup |

### Total Capstone Score: 60%

## Implementation Strategy

### Spec-Driven Development Approach

This capstone uses **spec-driven development** to minimize uncertainty. Each Lambda function has a detailed specification in `docs/specs/` that includes:

- Purpose and API endpoint
- Input/output schemas with JSON examples
- Error scenarios and status codes
- DynamoDB operations required
- Step-by-step implementation guidance
- Testing curl commands
- Claude Code prompt suggestions

**Follow this workflow:**

1. **Read the spec** - Understand requirements before coding
2. **Use AI prompts** - Leverage Claude Code with provided templates
3. **Implement incrementally** - Build one function at a time
4. **Test immediately** - Deploy and verify each function works
5. **Debug with logs** - Use CloudWatch Logs for troubleshooting

### Recommended Implementation Order

1. **CreateItem** - Start here to populate the database
2. **ListItems** - Verify items were created
3. **GetItem** - Test retrieving individual items
4. **UpdateItem** - Modify existing items
5. **DeleteItem** - Clean up test data

## Cost Estimation

### Expected AWS Costs

This capstone project should cost **under $1 USD** for the entire development and testing period.

| Service | Cost Estimate | Notes |
|---------|---------------|-------|
| DynamoDB | $0.00 - $0.10 | PAY_PER_REQUEST, minimal operations, Free Tier |
| Lambda | $0.00 - $0.20 | First 1M requests free, ~100 invocations |
| API Gateway | $0.00 - $0.50 | First 1M requests $3.50/million, ~50 requests |
| CloudWatch Logs | $0.00 - $0.10 | Minimal log ingestion, Free Tier |
| X-Ray | $0.00 - $0.10 | First 100k traces free |

**Total**: Under $1.00 USD

### Cost Mitigation

- ✅ Use AWS Free Tier (all students should stay within limits)
- ✅ Minimize testing to necessary verification only
- ✅ Delete stack immediately after demonstration
- ✅ Monitor AWS Billing Dashboard during development

**IMPORTANT**: Run `./scripts/delete.sh` after submitting to avoid ongoing charges.

For detailed cost breakdown, see [docs/COST_AND_CLEANUP.md](docs/COST_AND_CLEANUP.md).

## Timeline Guidance

### Session 10 (2 hours in-class)

| Time | Activity |
|------|----------|
| 0-15 min | Introduction, requirements review, clone repository |
| 15-30 min | Review SAM template, understand architecture |
| 30-90 min | Implement Lambda functions using Claude Code prompts |
| 90-110 min | Deploy and test with curl commands |
| 110-120 min | Troubleshooting, Q&A, cleanup planning |

### Homework (2-4 hours)

- Complete remaining Lambda function implementations
- Polish documentation (README, architecture diagram)
- Comprehensive testing of all CRUD operations
- Screenshot evidence collection (optional)
- Final deployment verification
- Submit GitHub repository URL

## Success Criteria

Your capstone is successful when:

✅ All 5 CRUD operations work correctly
✅ API returns proper HTTP status codes
✅ DynamoDB stores and retrieves products accurately
✅ SAM template deploys without errors
✅ CloudWatch Logs show function executions
✅ X-Ray traces display request flows
✅ Cost stays under $1 USD
✅ GitHub repository is portfolio-quality
✅ Documentation is complete and professional

## Getting Help

### Resources Available

1. **Function Specifications** - `docs/specs/` for detailed requirements
2. **Prompt Templates** - `docs/prompts/` for Claude Code assistance
3. **Testing Guide** - `docs/TESTING_GUIDE.md` for curl examples
4. **Debugging Guide** - `docs/prompts/05_DEBUGGING.md` for troubleshooting
5. **Instructor Support** - Ask questions during Session 10
6. **CloudWatch Logs** - First place to look for errors
7. **AWS Documentation** - Official guides for Lambda, DynamoDB, API Gateway

### Common Challenges

| Challenge | Solution |
|-----------|----------|
| Lambda function errors | Check CloudWatch Logs for stack traces |
| DynamoDB permission denied | Verify SAM template IAM policies |
| API Gateway 404 errors | Confirm endpoint paths match template |
| Deployment failures | Review CloudFormation events in console |
| Timeout errors | Increase Lambda timeout or optimize code |

## Portfolio Value

This capstone provides tangible evidence of your serverless expertise:

- **GitHub repository** demonstrating production-quality code
- **Architecture diagram** showing system design skills
- **Working REST API** with complete CRUD operations
- **Documentation** highlighting communication abilities
- **AWS experience** valued by employers in Colombia's tech market

Add this project to your:
- LinkedIn profile (project section)
- Resume (projects or technical skills)
- Portfolio website (case study)
- Job interviews (technical discussion)

---

## Next Steps

1. Read this entire document carefully
2. Review the [README.md](README.md) quick start guide
3. Study the function specifications in `docs/specs/`
4. Begin implementing with `docs/prompts/02_LAMBDA_IMPLEMENTATION.md`
5. Test frequently using `docs/TESTING_GUIDE.md`
6. Submit your GitHub repository URL when complete

**Good luck building your TechModa serverless API!** 🚀
