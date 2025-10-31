# AWS Credentials Setup for GitHub Codespaces

This guide explains how to configure AWS credentials for the TechModa Serverless Capstone project when using GitHub Codespaces.

## Overview

To deploy your serverless application to AWS from Codespaces, you need to configure AWS credentials. GitHub Codespaces supports two methods:

1. **Repository Secrets** (Recommended for students) - Credentials automatically available in all Codespaces
2. **User Secrets** (Recommended for personal projects) - Credentials available across all your Codespaces

This guide covers **Repository Secrets**, which is the recommended approach for bootcamp students.

## Prerequisites

Before starting, you need:
- AWS Access Key ID
- AWS Secret Access Key
- AWS Region (e.g., `us-east-1`)

If you don't have these credentials, ask your bootcamp instructor or AWS account administrator.

---

## Method 1: Configure Repository Secrets (Recommended for Students)

### Step 1: Navigate to Repository Settings

1. Go to your repository on GitHub: `https://github.com/YOUR_USERNAME/techmoda-serverless-capstone-starter`
2. Click on the **Settings** tab (requires repository admin access)
3. In the left sidebar, expand **Secrets and variables**
4. Click on **Codespaces**

### Step 2: Add AWS Credentials as Secrets

Add the following three secrets:

#### Secret 1: AWS_ACCESS_KEY_ID

1. Click **New repository secret**
2. **Name**: `AWS_ACCESS_KEY_ID`
3. **Value**: Your AWS Access Key ID (e.g., `AKIAIOSFODNN7EXAMPLE`)
4. Click **Add secret**

#### Secret 2: AWS_SECRET_ACCESS_KEY

1. Click **New repository secret**
2. **Name**: `AWS_SECRET_ACCESS_KEY`
3. **Value**: Your AWS Secret Access Key (e.g., `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`)
4. Click **Add secret**

#### Secret 3: AWS_DEFAULT_REGION

1. Click **New repository secret**
2. **Name**: `AWS_DEFAULT_REGION`
3. **Value**: Your preferred AWS region (e.g., `us-east-1`)
4. Click **Add secret**

### Step 3: Verify Secrets Configuration

After adding all three secrets, your Codespaces secrets page should show:

```
AWS_ACCESS_KEY_ID          Updated X seconds ago
AWS_SECRET_ACCESS_KEY      Updated X seconds ago
AWS_DEFAULT_REGION         Updated X seconds ago
```

**Important**: Secret values are hidden and cannot be viewed after creation. If you need to change them, delete and recreate the secret.

---

## Method 2: Configure User Secrets (Alternative)

If you want credentials available across all your Codespaces (not just this repository):

### Step 1: Navigate to User Settings

1. Go to your GitHub profile settings: `https://github.com/settings/profile`
2. In the left sidebar, click **Codespaces**
3. Scroll down to **Codespaces secrets**

### Step 2: Add Secrets

Follow the same steps as Method 1, but add secrets to your user account instead of the repository.

### Step 3: Grant Repository Access

For each secret:
1. Click on the secret name
2. Under **Repository access**, select repositories that should have access
3. Choose **Selected repositories** and add `techmoda-serverless-capstone-starter`

---

## Using AWS Credentials in Codespaces

### Automatic Configuration

When you open a Codespace with configured secrets, AWS CLI will automatically use them. The environment variables are available immediately.

### Verify Configuration

1. Open a new Codespace or rebuild an existing one
2. Open the terminal
3. Run the following command to verify AWS credentials are configured:

```bash
aws sts get-caller-identity
```

**Expected output:**

```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-username"
}
```

If you see an error like "Unable to locate credentials", the secrets are not configured correctly.

### Test AWS Access

Test that you can interact with AWS services:

```bash
# List S3 buckets (if you have permission)
aws s3 ls

# List DynamoDB tables
aws dynamodb list-tables

# Get current region
aws configure get region
```

---

## Configuring AWS CLI Manually (Fallback)

If secrets are not working or you prefer manual configuration:

### Step 1: Open Codespace Terminal

```bash
aws configure
```

### Step 2: Enter Credentials

```
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-east-1
Default output format [None]: json
```

**Note**: Manually configured credentials are stored in `~/.aws/credentials` and will be lost when the Codespace is rebuilt.

---

## Security Best Practices

### ✅ DO

- Use IAM user credentials with limited permissions (not root account)
- Rotate access keys regularly (every 90 days)
- Delete secrets immediately after the bootcamp if using temporary credentials
- Use repository secrets for shared projects
- Use user secrets for personal projects

### ❌ DON'T

- Never commit AWS credentials to Git (already protected by .gitignore)
- Never share your access keys with others
- Never use root account credentials
- Never post credentials in Slack, Discord, or public forums
- Never leave credentials in code comments

### Recommended IAM Permissions

Your AWS user should have the following permissions for this capstone:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:*",
        "lambda:*",
        "apigateway:*",
        "dynamodb:*",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:GetRole",
        "iam:PassRole",
        "logs:*",
        "s3:*"
      ],
      "Resource": "*"
    }
  ]
}
```

**Note**: Your bootcamp instructor may have already configured appropriate permissions. Contact them if you encounter permission errors.

---

## Troubleshooting

### Problem: "Unable to locate credentials"

**Solution**:
1. Verify secrets are created in GitHub Settings → Codespaces
2. Rebuild your Codespace (Codespaces menu → Rebuild Container)
3. Check secret names match exactly (case-sensitive):
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_DEFAULT_REGION`

### Problem: "An error occurred (UnauthorizedOperation)"

**Solution**:
- Your IAM user doesn't have sufficient permissions
- Contact your bootcamp instructor for permission updates
- Verify you're using the correct AWS account

### Problem: "The security token included in the request is expired"

**Solution**:
- Your access key has expired (common with temporary credentials)
- Request new credentials from your instructor
- Update the secrets in GitHub Settings

### Problem: Secrets not showing in environment

**Solution**:
1. Verify secrets are created at repository level (not user level)
2. Rebuild the Codespace completely
3. Check that you have admin access to the repository

---

## Alternative: AWS Vault (Advanced)

For advanced users who want to use temporary credentials with MFA:

```bash
# Install AWS Vault (already available in Codespaces)
aws-vault exec your-profile -- sam deploy
```

Refer to `aws_course_manager.py` in the main bootcamp repository for AWS Vault configuration.

---

## Quick Reference

### Environment Variables Used

| Variable | Purpose | Example Value |
|----------|---------|---------------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key | `wJalrXUtnFEMI/K7MDENG/...` |
| `AWS_DEFAULT_REGION` | Default AWS Region | `us-east-1` |

### Verification Commands

```bash
# Check if credentials are configured
aws sts get-caller-identity

# Check current region
echo $AWS_DEFAULT_REGION

# List environment variables (be careful not to expose secrets)
env | grep AWS_
```

---

## Support

If you encounter issues with AWS credentials:

1. Review this documentation
2. Check the [Troubleshooting](#troubleshooting) section
3. Verify with `aws sts get-caller-identity`
4. Contact your bootcamp instructor
5. Check AWS IAM console for user permissions

---

## Next Steps

Once credentials are configured:

1. ✅ Verify with `aws sts get-caller-identity`
2. ✅ Review the [README.md](README.md) for project overview
3. ✅ Start implementing Lambda functions
4. ✅ Deploy with `./scripts/deploy.sh`
5. ✅ Test your API with curl commands

---

**Security Note**: Remember to delete your CloudFormation stack after completing the capstone to avoid AWS charges:

```bash
./scripts/delete.sh
```
