# AWS Credentials Setup for GitHub Codespaces

This guide explains how to configure AWS credentials for the TechModa Serverless Capstone project when using GitHub Codespaces.

## Prerequisites

Before starting, you need:
- AWS Access Key ID
- AWS Secret Access Key
- AWS Region (e.g., `us-east-1`)

If you don't have these credentials, ask your bootcamp instructor or AWS account administrator.

---

## Method 1: Configure Repository Secrets (Recommended)

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

### Step 3: Apply Changes to Your Codespace

**IMPORTANT**: After adding or modifying secrets, you must restart your Codespace:

1. **If Codespace is running**:
   - Click on the Codespace name at the bottom left of VS Code
   - Select **Stop Current Codespace**
   - Wait for it to stop completely
   - Reopen the Codespace from GitHub

2. **If creating a new Codespace**:
   - The secrets will be available automatically

**Note**: Simply reloading the window is NOT sufficient. You must fully stop and restart the Codespace for the new secrets to be loaded.

### Step 4: Verify Secrets Configuration

After restarting your Codespace, verify the secrets were loaded:

```bash
# Check if environment variables are set
echo $AWS_ACCESS_KEY_ID
echo $AWS_DEFAULT_REGION

# Verify AWS credentials work
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

If you see an error like "Unable to locate credentials", the secrets were not loaded. Make sure you **stopped and restarted** the Codespace (not just reloaded).

---

## Method 2: Manual Configuration with AWS CLI (Alternative)

If you prefer not to use GitHub secrets or need temporary credentials:

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

### Step 3: Verify Configuration

```bash
aws sts get-caller-identity
```

**Note**: Manually configured credentials are stored in `~/.aws/credentials`. These will persist while your Codespace exists but will be lost if the Codespace is deleted or rebuilt.

---

## Test AWS Access

After configuring credentials with either method, test your AWS access:

```bash
# Verify identity
aws sts get-caller-identity

# Test DynamoDB access
aws dynamodb list-tables

# Check current region
aws configure get region

# List S3 buckets (if you have permission)
aws s3 ls
```

If all commands work without errors, your AWS credentials are configured correctly!

---

## Security Best Practices

### ✅ DO

- **Use IAM user credentials** with limited permissions (not root account)
- **Rotate access keys regularly** (every 90 days recommended)
- **Delete secrets** after the bootcamp if using temporary credentials
- **Keep credentials private** - never share with anyone
- **Use repository secrets** for bootcamp projects
- **Delete your CloudFormation stack** after testing to avoid charges

### ❌ DON'T

- **Never commit AWS credentials to Git** (already protected by .gitignore)
- **Never share your access keys** with other students
- **Never use root account credentials** for development
- **Never post credentials** in Slack, Discord, or public forums
- **Never leave credentials** in code comments or documentation
- **Never screenshot** or share your AWS_SECRET_ACCESS_KEY

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

## Common Issues

### Problem: "Unable to locate credentials"

**Solution**: You didn't restart your Codespace after adding secrets
1. Stop your Codespace completely
2. Reopen it from GitHub
3. Verify with `aws sts get-caller-identity`

### Problem: "An error occurred (UnauthorizedOperation)"

**Solution**: Insufficient IAM permissions
- Contact your bootcamp instructor
- Verify you're using the correct AWS account

### Problem: Secrets not working after restart

**Solution**: Check secret names (case-sensitive)
- Must be exactly: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`
- Delete and recreate if needed

---

## Next Steps

Once credentials are configured and verified:

1. ✅ Test with `aws sts get-caller-identity`
2. ✅ Review the [README.md](README.md) for implementation guide
3. ✅ Start implementing Lambda functions
4. ✅ Deploy with `./scripts/deploy.sh`
5. ✅ Test your API with curl commands

**Remember**: Delete your CloudFormation stack after completing the capstone to avoid AWS charges:

```bash
./scripts/delete.sh
```
