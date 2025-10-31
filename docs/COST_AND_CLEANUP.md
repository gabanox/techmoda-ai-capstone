# AWS Cost Estimation and Cleanup Guide

## Cost Breakdown

This capstone project is designed to stay **under $1 USD** for the entire development, testing, and demonstration period. Here's the detailed cost breakdown by service.

### DynamoDB

**Pricing Model**: PAY_PER_REQUEST (On-Demand)

**Cost Components**:
- **Write requests**: $1.25 per million write request units
- **Read requests**: $0.25 per million read request units
- **Storage**: $0.25 per GB-month

**Estimated Usage**:
- 10 CreateItem operations (writes)
- 20 GetItem operations (reads)
- 10 UpdateItem operations (writes)
- 5 DeleteItem operations (writes)
- 20 ListItems operations (Scan reads ~10 items each = 200 read units)
- Storage: <1 MB for ~10 products

**Calculation**:
- Write requests: 25 writes × $1.25 / 1,000,000 = $0.00003
- Read requests: 220 reads × $0.25 / 1,000,000 = $0.00006
- Storage: 0.001 GB × $0.25 = $0.00025

**DynamoDB Total**: **~$0.00034** (effectively $0.00)

**AWS Free Tier Coverage**:
- 25 GB storage (free)
- 2.5 million read requests per month (free)
- 1 million write requests per month (free)

Your usage is **100% covered by Free Tier**.

### AWS Lambda

**Pricing Model**: Pay per invocation + compute time

**Cost Components**:
- **Invocations**: $0.20 per million requests
- **Compute time**: $0.0000166667 per GB-second
- **Free Tier**: First 1 million requests + 400,000 GB-seconds per month

**Estimated Usage**:
- 100 total Lambda invocations across all 5 functions
- Average execution time: 200ms per invocation
- Memory: 1024 MB (1 GB) per function

**Calculation**:
- Invocations: 100 × $0.20 / 1,000,000 = $0.00002
- Compute time: 100 invocations × 0.2 seconds × 1 GB × $0.0000166667 = $0.00033

**Lambda Total**: **~$0.00035** (effectively $0.00)

**AWS Free Tier Coverage**:
- 1 million requests (free)
- 400,000 GB-seconds (free)
- Your usage: 100 requests + 20 GB-seconds

Your usage is **100% covered by Free Tier**.

### API Gateway

**Pricing Model**: Pay per API call

**Cost Components**:
- **REST API calls**: $3.50 per million requests (us-east-1)
- **Data transfer**: $0.09 per GB out (first 1 GB free)

**Estimated Usage**:
- 50 API requests during development/testing
- Average response size: 2 KB per request

**Calculation**:
- API calls: 50 × $3.50 / 1,000,000 = $0.000175
- Data transfer: 50 × 2 KB = 100 KB (well under 1 GB free tier)

**API Gateway Total**: **~$0.00018** (effectively $0.00)

**AWS Free Tier Coverage**:
- First 1 million API calls per month for first 12 months (free)
- First 1 GB data transfer out per month (free)

Your usage is **100% covered by Free Tier** (if within first 12 months).

### CloudWatch Logs

**Pricing Model**: Pay per GB ingested and stored

**Cost Components**:
- **Ingestion**: $0.50 per GB
- **Storage**: $0.03 per GB per month
- **Free Tier**: First 5 GB ingestion, 5 GB storage per month

**Estimated Usage**:
- 100 Lambda invocations × 5 log lines per invocation × 200 bytes per line = 0.1 MB
- Retention: 7 days (default)

**Calculation**:
- Ingestion: 0.0001 GB × $0.50 = $0.00005
- Storage: 0.0001 GB × $0.03 × (7/30) = $0.0000007

**CloudWatch Logs Total**: **~$0.00006** (effectively $0.00)

**AWS Free Tier Coverage**:
- 5 GB ingestion per month (free)
- 5 GB storage per month (free)

Your usage is **100% covered by Free Tier**.

### AWS X-Ray

**Pricing Model**: Pay per trace recorded and retrieved

**Cost Components**:
- **Traces recorded**: $5.00 per million traces
- **Traces retrieved**: $0.50 per million traces
- **Free Tier**: First 100,000 traces recorded per month (free)

**Estimated Usage**:
- 50 API requests = 50 traces recorded
- 10 trace retrievals (viewing in console)

**Calculation**:
- Traces recorded: 50 × $5.00 / 1,000,000 = $0.00025
- Traces retrieved: 10 × $0.50 / 1,000,000 = $0.000005

**X-Ray Total**: **~$0.00026** (effectively $0.00)

**AWS Free Tier Coverage**:
- 100,000 traces per month (free)
- 1 million traces retrieved per month (free)

Your usage is **100% covered by Free Tier**.

### CloudFormation

**Cost**: **$0.00** - CloudFormation service itself is free. You only pay for resources it creates (Lambda, DynamoDB, etc.).

### IAM

**Cost**: **$0.00** - IAM is always free. No charges for users, groups, roles, or policies.

## Total Estimated Cost

| Service | Estimated Cost | Free Tier Coverage |
|---------|----------------|-------------------|
| DynamoDB | $0.00034 | ✅ Fully covered |
| Lambda | $0.00035 | ✅ Fully covered |
| API Gateway | $0.00018 | ✅ Fully covered (first 12 months) |
| CloudWatch Logs | $0.00006 | ✅ Fully covered |
| X-Ray | $0.00026 | ✅ Fully covered |
| CloudFormation | $0.00 | ✅ Always free |
| IAM | $0.00 | ✅ Always free |

**Total**: **~$0.0012** (less than **$0.01**)

**Actual charge**: **$0.00** if within Free Tier limits

## Usage Assumptions

The above estimates assume:

- **Development period**: 1-2 days
- **Testing intensity**: 50 API requests total
- **Database size**: ~10 products (< 1 MB)
- **Active monitoring**: Minimal CloudWatch/X-Ray console usage
- **Lambda invocations**: ~100 total across all functions
- **No production traffic**: Only manual testing with curl

## Cost Optimization Best Practices

### 1. Delete Resources Immediately After Testing

Run cleanup as soon as you've demonstrated your working API:

```bash
sam delete --stack-name techmoda-capstone
```

This prevents any ongoing charges, even though they'd be minimal.

### 2. Use PAY_PER_REQUEST for DynamoDB

✅ **Already configured in template.yaml**

PAY_PER_REQUEST is more cost-effective than provisioned capacity for:
- Low traffic volumes
- Unpredictable usage patterns
- Development/testing workloads

**Alternative (provisioned)**: Would require paying for minimum capacity even when idle.

### 3. Set CloudWatch Logs Retention

✅ **Already configured in template.yaml (7 days)**

Prevents indefinite log accumulation. After 7 days, logs are automatically deleted.

### 4. Avoid Unnecessary Testing

- Test each function 2-3 times, not 100+ times
- Don't leave automated test scripts running in loops
- Delete test products after verification

### 5. Monitor AWS Billing Dashboard

Check your actual costs:
1. AWS Console → Billing Dashboard
2. View "Month-to-Date Costs by Service"
3. Verify charges align with expectations (should be $0.00)

## Cleanup Instructions

### Why Cleanup Matters

Even though this project costs nearly $0 during active use, AWS resources can accumulate charges if left running indefinitely:

- DynamoDB table continues to exist (minimal storage costs)
- CloudWatch Logs continue to store data (minimal storage costs)
- Lambda functions remain deployed (no cost unless invoked)
- API Gateway endpoint remains active (no cost unless called)

**Best Practice**: Delete all resources immediately after completing your capstone to maintain clean AWS hygiene.

### Method 1: SAM Delete Command (Recommended)

The fastest and safest way to remove all resources:

```bash
sam delete --stack-name techmoda-capstone
```

**Interactive prompts**:
```
Are you sure you want to delete the stack techmoda-capstone in the region us-east-1 ? [y/N]: y
Are you sure you want to delete the folder techmoda-capstone in S3 which contains the artifacts? [y/N]: y
```

**What gets deleted**:
- All 5 Lambda functions
- API Gateway REST API
- DynamoDB table (including all data)
- CloudWatch Log Groups
- IAM execution roles
- CloudFormation stack metadata
- S3 deployment bucket (artifacts)

**Duration**: 2-5 minutes

### Method 2: Delete Script (Alternative)

Use the provided convenience script:

```bash
./scripts/delete.sh
```

This script runs the same `sam delete` command with confirmation prompts.

### Method 3: AWS Console (Manual Fallback)

If `sam delete` fails, manually delete via CloudFormation console:

1. Go to AWS CloudFormation console
2. Select your stack (e.g., `techmoda-capstone`)
3. Click "Delete" button
4. Confirm deletion
5. Wait for status to show `DELETE_COMPLETE`

**Note**: Manual deletion via console is less reliable because it requires you to understand resource dependencies.

## Verification Steps

After running `sam delete`, verify all resources are gone:

### 1. Check CloudFormation

```bash
aws cloudformation describe-stacks --stack-name techmoda-capstone
```

**Expected output**: Error message indicating stack doesn't exist:
```
An error occurred (ValidationError) when calling the DescribeStacks operation:
Stack with id techmoda-capstone does not exist
```

### 2. Verify Lambda Functions Deleted

```bash
aws lambda list-functions --query "Functions[?contains(FunctionName, 'techmoda-capstone')]"
```

**Expected output**: Empty array `[]`

### 3. Verify DynamoDB Table Deleted

```bash
aws dynamodb list-tables --query "TableNames[?contains(@, 'techmoda-capstone')]"
```

**Expected output**: Empty array `[]`

### 4. Verify API Gateway Deleted

```bash
aws apigateway get-rest-apis --query "items[?contains(name, 'techmoda-capstone')]"
```

**Expected output**: Empty array `[]`

### 5. Check Billing Dashboard

1. Go to AWS Console → Billing Dashboard
2. View "Month-to-Date Costs by Service"
3. Verify no new charges appearing after deletion
4. Check "Free Tier" usage tracking

## Troubleshooting Deletion Failures

### Issue: Stack stuck in DELETE_IN_PROGRESS

**Cause**: CloudFormation waiting for resource dependencies

**Solution**: Wait 5-10 minutes. Some resources (like API Gateway) take time to delete.

### Issue: DELETE_FAILED status

**Cause**: Some resources failed to delete (e.g., DynamoDB table with DeletionProtection enabled)

**Solution**:

1. Check CloudFormation Events tab for specific error
2. Manually delete the problematic resource in AWS Console
3. Retry deletion:
   ```bash
   sam delete --stack-name techmoda-capstone --no-prompts
   ```

### Issue: "Stack cannot be deleted while in status DELETE_FAILED"

**Solution**: Force delete by skipping failed resources

```bash
aws cloudformation delete-stack \
  --stack-name techmoda-capstone \
  --retain-resources [ResourceLogicalId]
```

Replace `[ResourceLogicalId]` with the resource that failed to delete (from Events tab).

### Issue: S3 bucket not empty

**Cause**: SAM deployment artifacts remain in S3

**Solution**: Empty the bucket first

```bash
# Find the bucket name
aws cloudformation describe-stacks \
  --stack-name techmoda-capstone \
  --query "Stacks[0].Parameters[?ParameterKey=='SAMDeploymentBucket'].ParameterValue" \
  --output text

# Empty the bucket (replace YOUR_BUCKET_NAME)
aws s3 rm s3://YOUR_BUCKET_NAME --recursive

# Retry deletion
sam delete --stack-name techmoda-capstone
```

### Issue: Permissions error during deletion

**Cause**: IAM user lacks necessary permissions

**Solution**: Ensure your IAM user has these permissions:
- `cloudformation:DeleteStack`
- `lambda:DeleteFunction`
- `dynamodb:DeleteTable`
- `apigateway:DELETE`
- `iam:DeleteRole`

Ask your bootcamp instructor to verify IAM policy.

## Post-Cleanup Checklist

After successfully deleting your stack:

✅ Verify CloudFormation stack is gone
✅ Confirm no Lambda functions remain
✅ Check DynamoDB tables list is empty
✅ Verify API Gateway endpoints deleted
✅ Review Billing Dashboard (should show $0.00 new charges)
✅ Save GitHub repository URL for submission
✅ Keep screenshots of working API (if required)

## Cost Monitoring During Development

### Set Up Billing Alerts (Optional)

Receive email notifications if costs exceed thresholds:

1. AWS Console → Billing → Billing Preferences
2. Enable "Receive Billing Alerts"
3. Go to CloudWatch → Alarms → Billing
4. Create alarm:
   - Metric: Estimated Charges
   - Threshold: $1.00 USD
   - Notification: Your email

This ensures you're notified if costs unexpectedly exceed capstone budget.

### Check Free Tier Usage

Monitor how much Free Tier you've consumed:

1. AWS Console → Billing → Free Tier
2. Review usage for:
   - Lambda (invocations and compute time)
   - DynamoDB (read/write capacity)
   - API Gateway (API calls)
   - CloudWatch Logs (ingestion)

**Alarm signs**:
- Lambda invocations > 900,000/month (approaching limit)
- DynamoDB writes > 900,000/month (approaching limit)
- Any service showing >80% Free Tier consumption

For this capstone, you should see <0.01% Free Tier usage.

## Estimated Costs Beyond Free Tier

If you exceed AWS Free Tier limits (unlikely for this capstone), here are the charges:

### Scenario: 10,000 API Requests (Heavy Testing)

| Service | Cost |
|---------|------|
| API Gateway | 10,000 × $3.50/1M = $0.035 |
| Lambda | 10,000 × $0.20/1M = $0.002 |
| DynamoDB | Writes: $0.003, Reads: $0.001 |
| CloudWatch | $0.001 |
| X-Ray | $0.05 |

**Total**: **~$0.09** (still under $0.10)

### Scenario: 1 Week of Active Use

| Service | Cost |
|---------|------|
| DynamoDB Storage | 0.001 GB × $0.25 = $0.00025 |
| CloudWatch Storage | 0.01 GB × $0.03 = $0.0003 |
| Lambda (idle) | $0.00 |
| API Gateway (idle) | $0.00 |

**Total**: **~$0.0006** (less than $0.001)

Even with extended use, costs remain negligible.

## Summary

- **Expected cost**: **$0.00** (fully covered by AWS Free Tier)
- **Worst-case cost**: **Under $0.10** (if Free Tier exhausted)
- **Capstone budget**: **Under $1.00 USD** ✅ Achieved
- **Cleanup time**: **2-5 minutes**
- **Cost after cleanup**: **$0.00** (no ongoing charges)

## Additional Resources

- [AWS Pricing Calculator](https://calculator.aws/) - Estimate costs for other architectures
- [AWS Free Tier Details](https://aws.amazon.com/free/) - Full list of Free Tier services
- [DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/) - Detailed PAY_PER_REQUEST costs
- [Lambda Pricing](https://aws.amazon.com/lambda/pricing/) - Request and compute pricing
- [API Gateway Pricing](https://aws.amazon.com/api-gateway/pricing/) - REST API costs

## Questions?

If you see unexpected charges or have billing questions:

1. Check AWS Billing Dashboard for detailed breakdown
2. Review CloudWatch Logs for unusual activity
3. Ask your bootcamp instructor for assistance
4. Contact AWS Support (if available in your account tier)

**Remember**: Delete your stack immediately after demonstration to avoid any charges beyond capstone scope.
