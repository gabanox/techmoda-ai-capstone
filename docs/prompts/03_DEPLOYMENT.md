# Prompt Templates: Deployment

These prompts guide you through building and deploying your TechModa serverless application using AWS SAM.

## Prompt 3.1: Build SAM Application

```
I have implemented all Lambda functions and need to build the SAM application before deployment.

Project structure:
- template.yaml (SAM template)
- functions/list-items/index.js
- functions/create-item/index.js
- functions/get-item/index.js
- functions/update-item/index.js
- functions/delete-item/index.js

Please provide:
1. Command to build SAM application (sam build)
2. What happens during build process
3. Expected output and success indicators
4. Common build errors and solutions
```

## Prompt 3.2: Deploy SAM Application (Guided)

```
I have built my SAM application (sam build completed) and need to deploy it to AWS.

This is my first deployment and I want to use guided mode.

Requirements:
- Stack name: techmoda-capstone
- Region: us-east-1
- Capabilities: CAPABILITY_IAM (for IAM role creation)
- Save configuration to samconfig.toml

Please provide:
1. Command for guided deployment (sam deploy --guided)
2. Prompts I'll see and recommended answers
3. How to confirm deployment succeeded
4. How to retrieve API Gateway URL after deployment
```

## Prompt 3.3: Deploy SAM Application (Subsequent Deploys)

```
I have already deployed my SAM application once and need to redeploy after code changes.

I have samconfig.toml from previous deployment.

Please provide:
1. Command for quick redeployment (sam deploy)
2. What gets updated vs recreated
3. How to verify deployment succeeded
4. How to rollback if deployment fails
```

## Expected Outcomes

### After sam build

✅ `.aws-sam/build/` directory created
✅ Lambda functions compiled and packaged
✅ Dependencies resolved
✅ Build artifacts ready for deployment
✅ Success message displayed

### After sam deploy

✅ CloudFormation stack created/updated
✅ Lambda functions deployed
✅ API Gateway endpoint created
✅ DynamoDB table created
✅ IAM roles configured
✅ Outputs displayed (including API URL)

## Detailed Guidance

### Build Process

**Command**:
```bash
sam build
```

**What Happens**:
1. SAM reads `template.yaml`
2. Validates template syntax
3. Packages each Lambda function
4. Resolves dependencies (if package.json exists)
5. Creates build artifacts in `.aws-sam/build/`

**Success Output**:
```
Building codeuri: functions/list-items runtime: nodejs18.x ...
Running NodejsNpmBuilder:NpmPack
...
Build Succeeded

Built Artifacts  : .aws-sam/build
Built Template   : .aws-sam/build/template.yaml
```

### Guided Deployment

**Command**:
```bash
sam deploy --guided
```

**Prompts and Recommended Answers**:

```
Stack Name [sam-app]: techmoda-capstone
AWS Region [us-east-1]: us-east-1
#Shows you resources changes to be deployed and require a 'Y' to initiate deploy
Confirm changes before deploy [y/N]: y
#SAM needs permission to be able to create roles to connect to the resources in your template
Allow SAM CLI IAM role creation [Y/n]: Y
#Preserves the state of previously provisioned resources when an operation fails
Disable rollback [y/N]: N
ListItemsFunction may not have authorization defined, Is this okay? [y/N]: y
CreateItemFunction may not have authorization defined, Is this okay? [y/N]: y
GetItemFunction may not have authorization defined, Is this okay? [y/N]: y
UpdateItemFunction may not have authorization defined, Is this okay? [y/N]: y
DeleteItemFunction may not have authorization defined, Is this okay? [y/N]: y
Save arguments to configuration file [Y/n]: Y
SAM configuration file [samconfig.toml]: samconfig.toml
SAM configuration environment [default]: default
```

**Deployment Progress**:
```
Deploying with following values
===============================
Stack name                   : techmoda-capstone
Region                       : us-east-1
...

Initiating deployment
=====================
...

CloudFormation stack changeset
-------------------------------------------------------------------------------------------------
Operation                     LogicalResourceId             ResourceType
-------------------------------------------------------------------------------------------------
+ Add                         CreateItemFunction            AWS::Lambda::Function
+ Add                         DeleteItemFunction            AWS::Lambda::Function
+ Add                         GetItemFunction               AWS::Lambda::Function
+ Add                         ListItemsFunction             AWS::Lambda::Function
+ Add                         UpdateItemFunction            AWS::Lambda::Function
+ Add                         ProductsTable                 AWS::DynamoDB::Table
+ Add                         TechModaApi                   AWS::ApiGateway::RestApi
...
-------------------------------------------------------------------------------------------------

Changeset created successfully. ...

Deploy this changeset? [y/N]: y

2025-10-30 12:00:00 - Waiting for stack create/update to complete
...

Successfully created/updated stack - techmoda-capstone in us-east-1
```

**Outputs**:
```
CloudFormation outputs from deployed stack
-------------------------------------------------
Outputs
-------------------------------------------------
Key                 TechModaApi
Description         API Gateway endpoint URL
Value               https://abc123xyz.execute-api.us-east-1.amazonaws.com/Prod
-------------------------------------------------
```

**IMPORTANT**: Copy the API Gateway URL from the outputs!

### Subsequent Deployments

After first deployment, use simpler command:

**Command**:
```bash
sam build && sam deploy
```

No prompts - uses saved configuration from `samconfig.toml`.

## Troubleshooting Prompts

### Build Failures

```
My sam build command is failing with this error:

[Paste error message]

Please help me:
1. Identify the cause of the build failure
2. Check if template.yaml has syntax errors
3. Verify function paths are correct
4. Suggest fixes
```

### Deployment Failures

```
My sam deploy command is failing.

Error message:
[Paste error from CloudFormation]

Stack status: [CREATE_FAILED/UPDATE_FAILED/ROLLBACK_COMPLETE]

Please help me:
1. Interpret the CloudFormation error
2. Identify which resource failed to create
3. Suggest solutions (IAM permissions, resource limits, etc.)
4. How to delete failed stack and retry
```

### Missing API URL

```
My deployment succeeded but I don't see the API Gateway URL in the outputs.

Please help me:
1. Show me how to retrieve the API URL from CloudFormation
2. AWS CLI command to get stack outputs
3. How to find API Gateway URL in AWS Console
```

### Permission Errors

```
I'm getting permission errors during deployment:

Error: User is not authorized to perform: cloudformation:CreateStack

Please help me:
1. List required IAM permissions for SAM deployment
2. Verify my IAM user has necessary permissions
3. Contact bootcamp instructor if needed
```

## Validation After Deployment

### Check Stack Status

```bash
aws cloudformation describe-stacks \
  --stack-name techmoda-capstone \
  --query "Stacks[0].StackStatus" \
  --output text
```

**Expected**: `CREATE_COMPLETE` or `UPDATE_COMPLETE`

### List Stack Resources

```bash
aws cloudformation list-stack-resources \
  --stack-name techmoda-capstone
```

**Should See**:
- 5 Lambda functions
- 1 API Gateway
- 1 DynamoDB table
- IAM roles
- CloudWatch Log Groups

### Get API URL

```bash
aws cloudformation describe-stacks \
  --stack-name techmoda-capstone \
  --query "Stacks[0].Outputs[?OutputKey=='TechModaApi'].OutputValue" \
  --output text
```

### Test API Endpoint

```bash
curl -X GET https://[your-api-id].execute-api.us-east-1.amazonaws.com/Prod/products
```

**Expected**: 200 OK with `{"products": []}`

## Common Issues and Solutions

### Issue: "Stack already exists"

**Symptom**: Error during first deployment

**Solution Prompt**:
```
I'm getting "Stack techmoda-capstone already exists" error but this is my first deployment.

Please help me:
1. Check if a stack with this name exists in my account
2. Delete the existing stack if needed
3. Choose a different stack name
4. Retry deployment
```

### Issue: "CAPABILITY_IAM not provided"

**Symptom**: Deployment rejected

**Solution**: Answer "Y" to "Allow SAM CLI IAM role creation" prompt

### Issue: "No changes to deploy"

**Symptom**: SAM says no changes detected

**Solution Prompt**:
```
SAM deploy says "No changes to deploy" but I modified my Lambda function code.

Please help me:
1. Verify I ran sam build before sam deploy
2. Check if code changes are in the right location
3. Force redeployment if needed
```

### Issue: Long deployment time

**Normal**: First deployment takes 3-5 minutes
**Concern**: If >10 minutes, check CloudFormation Events

**Prompt**:
```
My deployment has been running for over 10 minutes.

Please help me:
1. Check CloudFormation Events for stuck resources
2. Identify what's taking long
3. Determine if I should cancel and retry
```

## Best Practices

✅ Always run `sam build` before `sam deploy`
✅ Save the API Gateway URL immediately after deployment
✅ Check CloudFormation console if deployment seems stuck
✅ Keep `samconfig.toml` in version control
✅ Use same stack name for subsequent deployments
✅ Verify deployment with simple curl test

## Next Steps

After successful deployment:

1. Save API Gateway URL
2. Test all endpoints with curl
3. Verify CloudWatch Logs are capturing execution
4. Check X-Ray traces
5. Proceed to [Testing Prompts](04_TESTING.md)
