# TechModa Capstone - Evaluation Rubric

## Overview

This rubric evaluates student submissions across three dimensions: **Technical Excellence (30%)**, **Documentation (15%)**, and **Business Relevance (15%)**, totaling **60% of the overall bootcamp grade**.

## Submission Requirements

**Deliverable**: GitHub repository URL containing:
- Complete SAM template (template.yaml)
- All 5 Lambda function implementations
- README.md with architecture and deployment instructions
- Documentation of testing approach

## Evaluation Criteria

### Technical Excellence (30%)

#### Criterion 1: All 5 CRUD Operations Functional (10%)

**Full Credit (10%)**:
- ✅ **ListItems** (GET /products): Returns array of products (or empty array) with 200 OK
- ✅ **CreateItem** (POST /products): Creates product with auto-generated UUID and timestamps, returns 201 Created
- ✅ **GetItem** (GET /products/{id}): Returns product with 200 OK or 404 Not Found for non-existent
- ✅ **UpdateItem** (PUT /products/{id}): Updates product with 200 OK, returns 404 for non-existent, updatedAt timestamp changes
- ✅ **DeleteItem** (DELETE /products/{id}): Deletes product with 200 OK, subsequent GET returns 404

**Partial Credit (5-9%)**:
- 4 out of 5 functions work correctly (8%)
- 3 out of 5 functions work correctly (6%)
- 2 out of 5 functions work correctly (4%)

**No Credit (0%)**:
- Fewer than 2 functions work
- Deployment fails
- Template.yaml invalid

**Testing Method**:
1. Clone repository
2. Deploy: `sam build && sam deploy --guided`
3. Test each endpoint with curl
4. Verify responses match specifications

#### Criterion 2: Proper Error Handling (5%)

**Full Credit (5%)**:
- ✅ Try/catch blocks present in all Lambda functions
- ✅ 404 responses for non-existent resources (GetItem, UpdateItem, optionally DeleteItem)
- ✅ 400 responses for validation errors (CreateItem missing name/price, invalid JSON)
- ✅ 500 responses for DynamoDB errors with error messages
- ✅ Error responses include `error` and `message` fields

**Partial Credit (2-4%)**:
- Basic try/catch present but inconsistent error responses (3%)
- Some error handling but missing 404 or 400 cases (2%)

**No Credit (0%)**:
- No error handling
- Functions crash without graceful responses
- Error responses missing or malformed

**Evaluation Tips**:
- Test with non-existent productId to verify 404
- Send POST request without required fields to verify 400
- Look for try/catch in code

#### Criterion 3: Code Quality and Readability (5%)

**Full Credit (5%)**:
- ✅ Clean, consistent code formatting (proper indentation, spacing)
- ✅ Meaningful variable names (`productId`, not `x` or `data`)
- ✅ Comments explaining key logic (DynamoDB operations, validation, error handling)
- ✅ No commented-out code or excessive debug logs
- ✅ Proper use of async/await
- ✅ DRY principle followed (no excessive repetition)

**Partial Credit (2-4%)**:
- Functional but inconsistent formatting (3%)
- Minimal comments but readable code (3%)
- Some poor naming conventions (2%)

**No Credit (0%)**:
- Unreadable code (no formatting, meaningless names)
- Excessive commented-out code
- Hard to understand logic flow

**Evaluation Tips**:
- Look for comments explaining non-obvious logic
- Check variable naming consistency
- Verify code is professionally formatted

#### Criterion 4: SAM Template Correctness (5%)

**Full Credit (5%)**:
- ✅ Valid YAML syntax (no syntax errors)
- ✅ All 5 Lambda functions defined with correct properties (Handler, Runtime, CodeUri, Policies)
- ✅ API Gateway configured with proper routes (GET, POST, PUT, DELETE)
- ✅ DynamoDB table defined with correct schema (productId as key)
- ✅ IAM policies grant necessary permissions (DynamoDBReadPolicy, DynamoDBCrudPolicy)
- ✅ Environment variables inject table name (PRODUCTS_TABLE: !Ref ProductsTable)
- ✅ Outputs section includes API Gateway URL

**Partial Credit (2-4%)**:
- Minor issues but deploys successfully (4%)
- Missing some properties but functional (3%)
- Overly permissive IAM policies (2%)

**No Credit (0%)**:
- Invalid YAML (deployment fails)
- Missing critical resources (Lambda functions, API Gateway, DynamoDB)
- Template does not deploy

**Evaluation Tips**:
- Verify `sam build` and `sam deploy` succeed
- Check CloudFormation console for stack resources
- Review IAM policies for least-privilege

#### Criterion 5: AWS Best Practices (5%)

**Full Credit (5%)**:
- ✅ IAM roles follow least-privilege principle (function-specific policies)
- ✅ X-Ray tracing enabled (`Tracing: Active` in template)
- ✅ CloudWatch Logs configured (automatic via SAM)
- ✅ CORS headers in all responses (`Access-Control-Allow-Origin: *`)
- ✅ DynamoDB PAY_PER_REQUEST billing mode
- ✅ Environment variables used (not hardcoded table names)

**Partial Credit (2-4%)**:
- Most best practices followed, minor omissions (4%)
- CORS missing or X-Ray not enabled (3%)
- IAM policies too broad but functional (2%)

**No Credit (0%)**:
- Hardcoded credentials (major security issue)
- No environment variables
- Missing CORS (API won't work from browsers)

**Evaluation Tips**:
- Check template for `Tracing: Active`
- Verify CORS headers in Lambda responses
- Review IAM policies for specificity

### Documentation (15%)

#### Criterion 6: README Completeness (5%)

**Full Credit (5%)**:
- ✅ Project overview (what it is, business context)
- ✅ Architecture description (components and their roles)
- ✅ Prerequisites listed (AWS CLI, SAM CLI, AWS credentials)
- ✅ Deployment instructions (step-by-step commands)
- ✅ Testing examples (curl commands for all endpoints)
- ✅ Cleanup instructions (how to delete resources)
- ✅ Professional formatting (headings, code blocks, lists)

**Partial Credit (2-4%)**:
- Basic instructions but missing some sections (3%)
- Adequate but not polished (2%)

**No Credit (0%)**:
- No README or minimal content
- Instructions don't work

**Evaluation Tips**:
- Can you deploy by following their README?
- Are testing examples sufficient to verify functionality?

#### Criterion 7: Architecture Diagram (5%)

**Full Credit (5%)**:
- ✅ Diagram present (text-based ASCII art, diagrams.py, draw.io, or image)
- ✅ Shows all key components (API Gateway, Lambda functions, DynamoDB)
- ✅ Indicates request flow (arrows or similar)
- ✅ Clear and understandable
- ✅ Labeled appropriately

**Partial Credit (2-4%)**:
- Simple but effective diagram (3%)
- Diagram present but unclear or incomplete (2%)

**No Credit (0%)**:
- No diagram
- Diagram is unreadable or incorrect

**Evaluation Tips**:
- Can you understand the architecture from the diagram alone?
- Are all components represented?

#### Criterion 8: Testing Examples (5%)

**Full Credit (5%)**:
- ✅ Curl commands for all 5 endpoints
- ✅ Sample request bodies included
- ✅ Expected responses documented
- ✅ Instructions clear enough to replicate tests
- ✅ Shows how to capture productId for use in other tests

**Partial Credit (2-4%)**:
- Basic curl examples but incomplete (3%)
- Examples present but not comprehensive (2%)

**No Credit (0%)**:
- No testing examples
- Examples don't work

**Evaluation Tips**:
- Try running their curl commands
- Verify examples match actual API behavior

### Business Relevance (15%)

#### Criterion 9: Solves Fashion Catalog Problem (7%)

**Full Credit (7%)**:
- ✅ Product schema appropriate for fashion e-commerce (name, description, price, category, imageUrl)
- ✅ CRUD operations support typical e-commerce workflows
- ✅ Implementation aligns with TechModa business context
- ✅ API design facilitates product catalog management
- ✅ Data model is sensible for fashion products

**Partial Credit (3-6%)**:
- Schema adequate but missing optional fields (5%)
- Basic CRUD but limited business alignment (4%)

**No Credit (0%)**:
- Schema doesn't match requirements
- Implementation doesn't address business need

**Evaluation Tips**:
- Does the product schema make sense for fashion?
- Can the API realistically manage a product catalog?

#### Criterion 10: Appropriate Technology Choices (5%)

**Full Credit (5%)**:
- ✅ Serverless architecture justified for use case (scalability, cost)
- ✅ DynamoDB suitable for product catalog (simple key-value, fast reads)
- ✅ API Gateway appropriate for REST API
- ✅ Node.js 18.x runtime for Lambda
- ✅ Design decisions demonstrate understanding of trade-offs

**Partial Credit (2-4%)**:
- Technologies used correctly but not optimally (3%)
- Adequate choices without strong justification (2%)

**No Credit (0%)**:
- Inappropriate architecture choices
- Doesn't leverage serverless benefits

**Evaluation Tips**:
- Is serverless a good fit for this use case?
- Are there obvious better alternatives not used?

#### Criterion 11: Cost-Consciousness (3%)

**Full Credit (3%)**:
- ✅ Uses AWS Free Tier services
- ✅ DynamoDB PAY_PER_REQUEST (not provisioned)
- ✅ Cleanup instructions provided
- ✅ Evidence of cost awareness in design (retention policies, timeouts)
- ✅ Project stays under $1 USD in testing

**Partial Credit (1-2%)**:
- Mostly cost-effective but some waste (2%)
- Basic cost awareness (1%)

**No Credit (0%)**:
- No consideration of cost
- Uses expensive alternatives unnecessarily

**Evaluation Tips**:
- Check DynamoDB billing mode in template
- Verify cleanup instructions exist
- Look for CloudWatch Logs retention settings

## Scoring Summary

| Category | Points |
|----------|--------|
| **Technical Excellence** | **30%** |
| 1. All 5 CRUD operations functional | 10% |
| 2. Proper error handling | 5% |
| 3. Code quality and readability | 5% |
| 4. SAM template correctness | 5% |
| 5. AWS best practices | 5% |
| **Documentation** | **15%** |
| 6. README completeness | 5% |
| 7. Architecture diagram | 5% |
| 8. Testing examples | 5% |
| **Business Relevance** | **15%** |
| 9. Solves fashion catalog problem | 7% |
| 10. Appropriate technology choices | 5% |
| 11. Cost-consciousness | 3% |
| **Total Capstone Score** | **60%** |

## Grade Ranges

- **Excellent (90-100% = 54-60 points)**: Exceeds expectations, all criteria met, professional quality
- **Good (75-89% = 45-53 points)**: Meets expectations, minor issues, solid implementation
- **Satisfactory (60-74% = 36-44 points)**: Meets minimum requirements, some issues, functional
- **Needs Improvement (<60% = <36 points)**: Does not meet requirements, significant issues

## Evaluation Workflow

### Step 1: Initial Review
1. Clone GitHub repository
2. Scan code for obvious issues (security, quality)
3. Review README and documentation
4. Check template.yaml structure

### Step 2: Deployment Test
1. Run `sam build`
2. Run `sam deploy --guided` (use unique stack name)
3. Note deployment success/failure
4. Capture API Gateway URL

### Step 3: Functional Testing
1. Test all 5 CRUD operations with curl
2. Verify expected responses
3. Test error cases (404, 400)
4. Document results

### Step 4: Code Review
1. Examine Lambda function implementations
2. Check error handling
3. Assess code quality
4. Review IAM policies

### Step 5: Scoring
1. Use this rubric to assign points
2. Document deductions with specific reasons
3. Provide constructive feedback

### Step 6: Cleanup
1. Delete test stack: `sam delete`
2. Verify all resources removed

## Comments Template

```
# TechModa Capstone Evaluation

Student: [Name]
GitHub Repository: [URL]
Evaluation Date: [Date]

## Technical Excellence (30%)
- All 5 CRUD operations functional: [X/10] - [comments]
- Proper error handling: [X/5] - [comments]
- Code quality and readability: [X/5] - [comments]
- SAM template correctness: [X/5] - [comments]
- AWS best practices: [X/5] - [comments]

**Subtotal**: [X/30]

## Documentation (15%)
- README completeness: [X/5] - [comments]
- Architecture diagram: [X/5] - [comments]
- Testing examples: [X/5] - [comments]

**Subtotal**: [X/15]

## Business Relevance (15%)
- Solves fashion catalog problem: [X/7] - [comments]
- Appropriate technology choices: [X/5] - [comments]
- Cost-consciousness: [X/3] - [comments]

**Subtotal**: [X/15]

## Total Score: [X/60] ([X]%)

## Strengths:
- [Strength 1]
- [Strength 2]
- [Strength 3]

## Areas for Improvement:
- [Improvement 1]
- [Improvement 2]
- [Improvement 3]

## Overall Comments:
[Detailed feedback on implementation, what worked well, what could be improved, portfolio readiness]
```

## Common Deductions

### Technical
- **-2 points**: Missing error handling in one or more functions
- **-3 points**: One CRUD operation doesn't work
- **-2 points**: Poor code formatting or no comments
- **-1 point**: Missing CORS headers
- **-2 points**: IAM policies too broad (not least-privilege)

### Documentation
- **-2 points**: Incomplete README (missing deployment steps)
- **-3 points**: No architecture diagram
- **-2 points**: No testing examples
- **-1 point**: Poor formatting or unclear instructions

### Business Relevance
- **-2 points**: Product schema missing important fields
- **-1 point**: No cleanup instructions
- **-1 point**: Design doesn't demonstrate cost awareness

## Academic Integrity

### Plagiarism Check

Compare submissions for:
- Identical code (beyond generated boilerplate)
- Same variable names and comments
- Identical README content

**If plagiarism suspected**:
1. Document evidence
2. Follow institution's academic integrity policy
3. Consider interview to assess understanding

### Acceptable Collaboration

Students may:
- Discuss architecture approaches
- Share debugging strategies
- Use provided prompt templates
- Leverage Claude Code for generation

Students may NOT:
- Copy Lambda function code from each other
- Share complete implementations
- Submit someone else's work

## Questions and Edge Cases

**Q: Student added extra features beyond requirements**
A: Award full credit for required features. Extra features don't add points but demonstrate initiative (note in comments).

**Q: Deployment works but costs exceed $1**
A: Verify they're using Free Tier services. Deduct 1-2 points if using unnecessarily expensive alternatives.

**Q: Student used Python instead of Node.js**
A: Requirement was Node.js 18.x. Significant deduction (-10 points) unless explicitly approved.

**Q: README is minimal but code is excellent**
A: Grade according to rubric. Both documentation and technical excellence are required.

**Q: One function has minor bug but generally works**
A: Partial credit. Deduct based on severity (1-2 points for minor issues).

## Contact

For grading questions or rubric clarifications, contact [Bootcamp Coordinator/Instructor Name].
