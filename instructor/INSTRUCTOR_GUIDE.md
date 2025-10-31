# TechModa Capstone - Instructor Guide

## Overview

This guide helps instructors facilitate Session 10 (the capstone session), support students during implementation, evaluate submissions, and troubleshoot common issues.

## Session 10 Timeline (120 minutes)

### 0-15 min: Introduction and Setup

**Instructor Activities**:
- Introduce capstone project and business context (TechModa fashion e-commerce)
- Review evaluation rubric (60% of bootcamp grade)
- Explain deliverables (GitHub repository URL)
- Emphasize cost constraints (under $1 USD, AWS Free Tier)

**Student Activities**:
- Clone starter repository
- Verify AWS CLI and SAM CLI installations
- Confirm AWS credentials are configured
- Test `aws sts get-caller-identity` and `sam --version`

**Common Issues**:
- AWS CLI/SAM CLI not installed → Direct to [docs/prompts/01_ENVIRONMENT_SETUP.md](../docs/prompts/01_ENVIRONMENT_SETUP.md)
- Credentials not configured → Help with `aws configure`
- Permission errors → Verify IAM user has necessary policies

### 15-30 min: Architecture Review

**Instructor Activities**:
- Walk through [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md)
- Explain API Gateway → Lambda → DynamoDB flow
- Review SAM template structure (template.yaml)
- Discuss each Lambda function's responsibility
- Show DynamoDB schema (productId, name, price, etc.)

**Student Activities**:
- Read ARCHITECTURE.md
- Examine template.yaml
- Review function specifications in docs/specs/
- Ask clarifying questions

**Key Points to Emphasize**:
- RESTful API design (GET, POST, PUT, DELETE)
- Serverless architecture benefits (no servers, auto-scaling, pay-per-use)
- AWS SAM simplifies infrastructure as code
- DynamoDB PAY_PER_REQUEST is cost-effective for low volumes

### 30-90 min: Lambda Implementation

**Instructor Activities**:
- Demonstrate using one Lambda function (e.g., ListItems)
- Show how to use prompts from [docs/prompts/02_LAMBDA_IMPLEMENTATION.md](../docs/prompts/02_LAMBDA_IMPLEMENTATION.md)
- Walk through Claude Code workflow:
  1. Copy prompt
  2. Paste to Claude Code
  3. Review generated code
  4. Save to correct location
  5. Deploy and test
- Encourage students to start with CreateItem (to populate database)
- Circulate to help individual students

**Student Activities**:
- Implement all 5 Lambda functions using Claude Code
- Follow function specifications in docs/specs/
- Use prompt templates to generate implementations
- Deploy incrementally (test each function before moving to next)

**Recommended Implementation Order**:
1. **CreateItem** (POST /products) - Generate test data
2. **ListItems** (GET /products) - Verify data exists
3. **GetItem** (GET /products/{id}) - Test single retrieval
4. **UpdateItem** (PUT /products/{id}) - Modify data
5. **DeleteItem** (DELETE /products/{id}) - Clean up test data

**Support Strategies**:
- Point to relevant specs for each function
- Help with AWS SDK v3 syntax if students struggle
- Verify environment variables (PRODUCTS_TABLE) are being used
- Check CORS headers are included in responses
- Remind about proper API Gateway response format

### 90-110 min: Deployment and Testing

**Instructor Activities**:
- Demonstrate `sam build && sam deploy --guided`
- Show how to retrieve API Gateway URL from outputs
- Walk through testing with curl ([docs/TESTING_GUIDE.md](../docs/TESTING_GUIDE.md))
- Demonstrate CloudWatch Logs access
- Show X-Ray traces (optional, time permitting)

**Student Activities**:
- Build and deploy SAM application
- Test all 5 endpoints with curl
- Verify responses match expected outputs
- Check CloudWatch Logs for execution logs
- Debug any failing tests

**Common Deployment Issues**:
- CAPABILITY_IAM not allowed → Students must answer "Y" to IAM prompts
- Stack already exists → Help delete old stack or choose new name
- Deployment timeout → Check CloudFormation console for stuck resources

**Testing Support**:
- Provide curl command examples
- Help capture productId from CreateItem response for use in other tests
- Verify HTTP status codes (200, 201, 404, 500)
- Check error responses are properly formatted

### 110-120 min: Troubleshooting and Q&A

**Instructor Activities**:
- Address common errors (see Troubleshooting section below)
- Answer architecture questions
- Help students debug failing functions
- Discuss cleanup procedures (sam delete)
- Remind about submission deadline and requirements

**Student Activities**:
- Fix any remaining issues
- Complete testing verification
- Start documentation (README updates)
- Ask final questions

**Wrap-Up Checklist**:
- ✅ All 5 CRUD operations working
- ✅ API Gateway URL accessible
- ✅ CloudWatch Logs showing executions
- ✅ No permission errors
- ✅ Students understand how to delete resources

## Learning Objectives

By the end of Session 10, students should demonstrate:

1. **Serverless Architecture Design**
   - Design event-driven systems with Lambda, API Gateway, DynamoDB
   - Understand serverless vs. traditional architectures
   - Apply AWS Well-Architected principles

2. **RESTful API Implementation**
   - Implement proper HTTP methods (GET, POST, PUT, DELETE)
   - Return appropriate status codes (200, 201, 404, 500)
   - Structure JSON request/response payloads

3. **Infrastructure as Code**
   - Write and deploy AWS SAM templates
   - Define resources declaratively
   - Manage IAM roles with least-privilege

4. **Manual API Testing**
   - Test endpoints with curl
   - Interpret HTTP responses
   - Verify CRUD operations

5. **Serverless Debugging**
   - Analyze CloudWatch Logs
   - Interpret X-Ray traces
   - Diagnose permission issues

6. **AWS Cost Management**
   - Estimate serverless costs
   - Understand Free Tier limits
   - Clean up resources properly

7. **AI-Accelerated Development**
   - Use Claude Code for implementation
   - Write effective prompts
   - Debug with AI assistance

8. **Technical Documentation**
   - Create architecture diagrams
   - Write deployment instructions
   - Document APIs with examples

9. **AWS Best Practices**
   - Security (IAM least-privilege)
   - Observability (CloudWatch, X-Ray)
   - Cost optimization

## Common Student Challenges and Solutions

### Challenge 1: Environment Setup Issues

**Symptoms**:
- AWS CLI or SAM CLI not found
- Credentials invalid
- Permission errors

**Solutions**:
- Direct to [docs/prompts/01_ENVIRONMENT_SETUP.md](../docs/prompts/01_ENVIRONMENT_SETUP.md)
- Verify PATH includes AWS CLI/SAM CLI binaries
- Test credentials: `aws sts get-caller-identity`
- Confirm IAM user has necessary permissions (CloudFormation, Lambda, DynamoDB, API Gateway, IAM)

### Challenge 2: Lambda Function Errors

**Symptoms**:
- 500 Internal Server Error from API
- CloudWatch Logs show JavaScript errors
- DynamoDB permission errors

**Solutions**:
- Check CloudWatch Logs for specific error
- Verify AWS SDK v3 imports are correct
- Confirm environment variable PRODUCTS_TABLE is being read
- Check DynamoDB policies in template.yaml (DynamoDBReadPolicy, DynamoDBCrudPolicy)
- Verify API Gateway response format (statusCode, headers, body)

**Common Code Issues**:
```javascript
// WRONG: body is not a string
return {
  statusCode: 200,
  body: { products: [] }  // ❌ Should be JSON.stringify()
};

// CORRECT:
return {
  statusCode: 200,
  body: JSON.stringify({ products: [] })  // ✅
};
```

### Challenge 3: Path Parameter Issues (GetItem, UpdateItem, DeleteItem)

**Symptoms**:
- "Cannot read property 'id' of undefined"
- Functions fail to extract productId

**Solutions**:
- Verify API Gateway route has `{id}` parameter in template.yaml
- Check extraction: `const productId = event.pathParameters.id`
- Add safety check:
  ```javascript
  if (!event.pathParameters || !event.pathParameters.id) {
    return {
      statusCode: 400,
      headers: {...},
      body: JSON.stringify({ error: 'Missing product ID' })
    };
  }
  ```

### Challenge 4: JSON Parse Errors (CreateItem, UpdateItem)

**Symptoms**:
- SyntaxError: Unexpected token in JSON
- Request body not being parsed

**Solutions**:
- Explain that `event.body` is a JSON string, not an object
- Show safe parsing:
  ```javascript
  let body;
  try {
    body = JSON.parse(event.body);
  } catch (error) {
    return {
      statusCode: 400,
      headers: {...},
      body: JSON.stringify({ error: 'Invalid JSON' })
    };
  }
  ```

### Challenge 5: DynamoDB Scan Returns Empty (ListItems)

**Symptoms**:
- GET /products returns empty array even after creating products

**Solutions**:
- Verify CreateItem function actually created products (check CloudWatch Logs)
- Check DynamoDB console to see if items exist
- Verify table name matches: `process.env.PRODUCTS_TABLE`
- Test GetItem with known productId to isolate issue

### Challenge 6: UpdateItem Not Working

**Symptoms**:
- 404 Not Found even though product exists
- Updates don't persist

**Solutions**:
- Verify UpdateItem checks existence first (GetItem before UpdateItem)
- Check UpdateExpression syntax:
  ```javascript
  UpdateExpression: 'SET price = :price, updatedAt = :updatedAt'
  ExpressionAttributeValues: {
    ':price': 69.99,
    ':updatedAt': new Date().toISOString()
  }
  ```
- Ensure `ReturnValues: 'ALL_NEW'` is set to return updated item

### Challenge 7: Deployment Failures

**Symptoms**:
- CloudFormation stack stuck or failed
- Resources not created

**Solutions**:
- Check CloudFormation console Events tab for specific errors
- Common causes:
  - IAM permissions: Student didn't allow IAM role creation
  - Resource limits: Exceeded service quotas (unlikely)
  - Invalid template: YAML syntax errors
- Retry deployment after fixing issue
- Delete failed stack: `aws cloudformation delete-stack --stack-name techmoda-capstone`

### Challenge 8: Testing Confusion

**Symptoms**:
- Students don't know how to test
- Can't find API Gateway URL
- Curl commands not working

**Solutions**:
- Show how to get API URL: CloudFormation Outputs or `aws cloudformation describe-stacks`
- Provide curl examples from [docs/TESTING_GUIDE.md](../docs/TESTING_GUIDE.md)
- Demonstrate capturing productId:
  ```bash
  RESPONSE=$(curl -s -X POST $API_URL/products -H "Content-Type: application/json" -d '{"name":"Test","price":99.99}')
  PRODUCT_ID=$(echo $RESPONSE | jq -r '.productId')
  echo $PRODUCT_ID
  ```
- Note: `jq` might not be installed; have students manually copy productId if needed

## How to Support Students

### During Implementation

1. **Encourage incremental development**: Test each function before moving to next
2. **Promote prompt usage**: Students should leverage Claude Code with provided templates
3. **Emphasize specs**: Direct students to docs/specs/ for detailed requirements
4. **Show CloudWatch Logs early**: Debugging starts with logs
5. **Don't give complete solutions**: Guide students to discover issues themselves

### When Students Are Stuck

**Do's**:
- ✅ Ask diagnostic questions ("What does CloudWatch Logs show?")
- ✅ Point to relevant documentation (specs, prompts, guides)
- ✅ Show how to interpret errors
- ✅ Demonstrate debugging workflow
- ✅ Encourage AI assistance (Claude Code)

**Don'ts**:
- ❌ Write code for students
- ❌ Take over their keyboard
- ❌ Give answers without explanation
- ❌ Skip debugging steps

### Time Management

- **30 min mark**: Students should be implementing functions
- **60 min mark**: At least 2-3 functions implemented
- **90 min mark**: All functions implemented, starting deployment
- **100 min mark**: Deployment complete, testing in progress
- **110 min mark**: All tests passing, debugging edge cases

**If Students Fall Behind**:
- Prioritize CreateItem, ListItems, GetItem (core CRUD)
- UpdateItem and DeleteItem can be homework
- Ensure students understand concepts even if implementation incomplete
- Extend support during homework hours

## How to Evaluate Submissions

### Required Deliverable

Students must submit:
- **GitHub repository URL** with complete, working implementation

### Evaluation Checklist

#### Technical Excellence (30%)

**All 5 CRUD operations functional (10%)**:
- ✅ ListItems returns products array (empty or populated)
- ✅ CreateItem returns 201 with new product (including productId, timestamps)
- ✅ GetItem returns 200 with product or 404 for non-existent
- ✅ UpdateItem returns 200 with updated product or 404
- ✅ DeleteItem returns 200 with success message

**Test by**:
1. Clone student's repository
2. Deploy to your AWS account: `sam build && sam deploy --guided`
3. Run curl tests for all endpoints
4. Verify responses match expectations

**Proper error handling (5%)**:
- ✅ Try/catch blocks in Lambda functions
- ✅ 404 for non-existent resources (GetItem, UpdateItem optional for DeleteItem)
- ✅ 400 for validation errors (CreateItem missing name/price)
- ✅ 500 for DynamoDB errors with error messages

**Code quality and readability (5%)**:
- ✅ Clean, consistent formatting
- ✅ Meaningful variable names
- ✅ Comments explaining logic
- ✅ No commented-out code or debug console.logs

**SAM template correctness (5%)**:
- ✅ Valid YAML syntax
- ✅ All 5 Lambda functions defined
- ✅ API Gateway with correct routes
- ✅ DynamoDB table with proper schema
- ✅ IAM policies (DynamoDB permissions)
- ✅ Environment variables injected

**AWS best practices (5%)**:
- ✅ IAM least-privilege (function-specific policies)
- ✅ X-Ray tracing enabled
- ✅ CloudWatch Logs configured
- ✅ CORS headers in responses
- ✅ PAY_PER_REQUEST billing for DynamoDB

#### Documentation (15%)

**README completeness (5%)**:
- ✅ Project overview and purpose
- ✅ Architecture description
- ✅ Deployment instructions (prerequisites, commands)
- ✅ Testing examples (curl commands)
- ✅ Cleanup instructions

**Architecture diagram (5%)**:
- ✅ Diagram present (text-based, diagrams.py, or draw.io)
- ✅ Shows all components (API Gateway, Lambda, DynamoDB)
- ✅ Request flow indicated
- ✅ Clear and understandable

**Testing examples (5%)**:
- ✅ Curl commands for all 5 endpoints
- ✅ Sample request bodies
- ✅ Expected responses documented
- ✅ Clear instructions

#### Business Relevance (15%)

**Solves fashion catalog problem (7%)**:
- ✅ Product schema appropriate (name, price, description, category, imageUrl)
- ✅ CRUD operations support e-commerce use case
- ✅ Implementation aligns with TechModa business context

**Appropriate technology choices (5%)**:
- ✅ Serverless architecture justified for use case
- ✅ DynamoDB suitable for product catalog
- ✅ API Gateway appropriate for REST API
- ✅ Cost-effective design decisions

**Cost-consciousness (3%)**:
- ✅ Uses AWS Free Tier services
- ✅ PAY_PER_REQUEST billing mode
- ✅ Cleanup instructions provided
- ✅ Evidence of cost awareness in design

### Grading Rubric

See [EVALUATION_RUBRIC.md](EVALUATION_RUBRIC.md) for detailed scoring criteria.

### Red Flags

**Automatic grade reduction**:
- ❌ Plagiarism (identical code from another student)
- ❌ Doesn't deploy (CloudFormation errors, invalid template)
- ❌ Major functions don't work (< 3 of 5 CRUD operations)
- ❌ No documentation (README empty or minimal)
- ❌ Hardcoded credentials or secrets

**Minor deductions**:
- ⚠️ Missing error handling
- ⚠️ Incomplete documentation
- ⚠️ Poor code formatting
- ⚠️ No architecture diagram

## What to Look for in Working Implementations

### Excellent Implementations (90-100%)

- All 5 CRUD operations work flawlessly
- Comprehensive error handling (400, 404, 500)
- Clean, well-commented code
- Complete documentation with diagrams
- Proper AWS best practices (IAM, X-Ray, CORS)
- Evidence of testing (test scripts, screenshots)
- Professional README suitable for portfolio

### Good Implementations (75-89%)

- All 5 CRUD operations work
- Basic error handling (404 for non-existent)
- Readable code with some comments
- Adequate documentation
- Most AWS best practices followed
- Successful deployment and testing

### Satisfactory Implementations (60-74%)

- 4-5 CRUD operations work
- Minimal error handling (try/catch present)
- Functional but less polished code
- Basic README with deployment steps
- Deploys successfully
- Some AWS best practices

### Needs Improvement (<60%)

- Fewer than 4 CRUD operations work
- Poor or missing error handling
- Difficult to understand code
- Minimal or no documentation
- Deployment issues
- Security concerns (hardcoded credentials)

## Troubleshooting Tips for Instructors

### Quick Diagnosis

**If student says "it doesn't work"**:
1. Ask: "What specific error do you see?"
2. Check: CloudWatch Logs for Lambda execution
3. Verify: Deployment succeeded (CloudFormation status)
4. Test: Simple curl command yourself

**If deployment fails**:
1. Check: CloudFormation Events tab
2. Look for: Resource-specific error messages
3. Common: IAM permission issues, invalid YAML
4. Solution: Delete stack, fix issue, redeploy

**If function returns 500**:
1. Check: CloudWatch Logs immediately
2. Look for: JavaScript errors, DynamoDB errors
3. Common: Missing await, wrong SDK syntax, permission issues
4. Solution: Fix code, redeploy

### Common Quick Fixes

**Missing API URL**:
```bash
aws cloudformation describe-stacks --stack-name techmoda-capstone --query "Stacks[0].Outputs"
```

**Check DynamoDB items**:
```bash
aws dynamodb scan --table-name techmoda-capstone-Products
```

**View recent Lambda logs**:
```bash
aws logs tail /aws/lambda/techmoda-capstone-ListItems --since 5m
```

**Force delete stuck stack**:
```bash
aws cloudformation delete-stack --stack-name techmoda-capstone
```

## Post-Session Follow-Up

### Homework Expectations

Students should complete:
- ✅ All 5 Lambda functions fully implemented and tested
- ✅ Comprehensive README documentation
- ✅ Architecture diagram
- ✅ Evidence of working implementation (screenshots optional)
- ✅ GitHub repository ready for submission

### Office Hours Support

Be available for:
- Debugging complex issues
- Architecture questions
- Deployment problems
- Documentation review (optional)

### Submission Deadline

- Clearly communicate deadline
- Specify submission format (GitHub URL via LMS/email)
- Remind students to cleanup resources after submission
- Provide grace period for technical difficulties (1-2 days)

## Resources for Instructors

### Reference Implementation

See [SOLUTION_NOTES.md](SOLUTION_NOTES.md) for implementation patterns (not full solutions).

### Quick Links

- [Function Specifications](../docs/specs/)
- [Testing Guide](../docs/TESTING_GUIDE.md)
- [Architecture Documentation](../docs/ARCHITECTURE.md)
- [Cost and Cleanup](../docs/COST_AND_CLEANUP.md)
- [Prompt Templates](../docs/prompts/)

### AWS Console Links

- CloudFormation: https://console.aws.amazon.com/cloudformation
- Lambda: https://console.aws.amazon.com/lambda
- DynamoDB: https://console.aws.amazon.com/dynamodb
- API Gateway: https://console.aws.amazon.com/apigateway
- CloudWatch: https://console.aws.amazon.com/cloudwatch
- X-Ray: https://console.aws.amazon.com/xray

## FAQs from Students

**Q: Can I use Python instead of Node.js?**
A: No, capstone requires Node.js 18.x for consistency in evaluation.

**Q: Do I need to write tests?**
A: No automated tests required. Manual testing with curl is sufficient.

**Q: Can I add extra features (authentication, image upload)?**
A: Focus on core CRUD first. Extra features are optional but not required for full credit.

**Q: What if I exceed $1 cost?**
A: Unlikely with proper usage. If concerned, monitor AWS Billing Dashboard. Delete resources immediately after testing.

**Q: Can I resubmit if I find bugs?**
A: Depends on policy. Generally, one resubmission allowed within 24 hours of deadline.

**Q: Do I need to include evidence (screenshots)?**
A: Not required but recommended for showcasing working implementation.

## Contact and Support

For instructor questions or issues with this guide:
- Review [CAPSTONE_OVERVIEW.md](../CAPSTONE_OVERVIEW.md)
- Check [AWS SAM Documentation](https://docs.aws.amazon.com/serverless-application-model/)
- AWS Bootcamp instructor community/Slack

---

**Good luck facilitating an excellent capstone experience!**
