# Prompt Templates: Environment Setup

These prompts help you install and configure the required tools for deploying your TechModa serverless API.

## Prompt 1.1: AWS CLI Installation (macOS)

```
I need to install AWS CLI v2 on macOS to deploy serverless applications.

Requirements:
- Latest AWS CLI v2
- Installation via official installer (not Homebrew)
- Verification steps to confirm installation

Please provide:
1. Download command or URL for official AWS CLI v2 installer for macOS
2. Installation steps
3. Verification command to check version
4. Basic configuration command for AWS credentials
```

## Prompt 1.2: AWS CLI Installation (Windows)

```
I need to install AWS CLI v2 on Windows 10/11 to deploy serverless applications.

Requirements:
- Latest AWS CLI v2
- Installation via MSI installer
- Verification steps

Please provide:
1. Download URL for AWS CLI v2 Windows installer
2. Installation steps
3. Verification command in PowerShell/CMD
4. Configuration command for AWS credentials
```

## Prompt 1.3: AWS CLI Installation (Linux)

```
I need to install AWS CLI v2 on Linux to deploy serverless applications.

My Linux distribution: [Ubuntu/Debian/Amazon Linux/etc]

Requirements:
- Latest AWS CLI v2
- Installation via official method
- Verification steps

Please provide:
1. Commands to download and install AWS CLI v2 on my distribution
2. Installation steps
3. Verification command to check version
4. Configuration command for AWS credentials
```

## Prompt 1.4: AWS SAM CLI Installation

```
I have AWS CLI v2 installed and need to install AWS SAM CLI to deploy serverless applications.

Environment: [macOS/Windows/Linux]

Requirements:
- Latest SAM CLI version
- Integration with existing AWS CLI credentials
- Verification of installation

Please provide:
1. Installation command for my OS
2. Verification command (sam --version)
3. Quick test command to validate SAM is working
```

## Prompt 1.5: Configure AWS Credentials

```
I need to configure AWS credentials for the AAD Bootcamp to deploy serverless applications in us-east-1.

I have:
- AWS Access Key ID
- AWS Secret Access Key

Please provide:
1. Command to configure AWS credentials (aws configure)
2. Prompts I'll see and what to enter
3. How to verify credentials are working (aws sts get-caller-identity)
4. Recommended default region (us-east-1) and output format (json)
```

## Expected Outcomes

After completing environment setup:

✅ AWS CLI v2 installed and accessible via `aws --version`
✅ SAM CLI installed and accessible via `sam --version`
✅ AWS credentials configured in `~/.aws/credentials`
✅ Default region set to `us-east-1`
✅ Can successfully run `aws sts get-caller-identity` to verify credentials

## Troubleshooting Prompts

### If AWS CLI Not Found

```
I installed AWS CLI but the command 'aws' is not found in my terminal.

My operating system: [macOS/Windows/Linux]

Installation method I used: [describe]

Error message: [paste error]

Please help me:
1. Check if AWS CLI is actually installed
2. Add AWS CLI to my PATH
3. Verify the installation worked
```

### If SAM CLI Not Found

```
I installed SAM CLI but the command 'sam' is not found in my terminal.

My operating system: [macOS/Windows/Linux]

Installation method I used: [describe]

AWS CLI version: [output of aws --version]

Please help me:
1. Check if SAM CLI is installed correctly
2. Add SAM CLI to my PATH
3. Verify SAM CLI can find AWS credentials
```

### If Credentials Invalid

```
I configured AWS credentials but I'm getting authentication errors.

Error message:
[paste error from aws sts get-caller-identity or sam deploy]

Please help me:
1. Verify my credentials file format is correct
2. Check if my Access Key ID and Secret Access Key are valid
3. Confirm I'm using the right AWS profile
4. Test connectivity to AWS
```

## Next Steps

Once environment setup is complete, proceed to:
- [Lambda Implementation Prompts](02_LAMBDA_IMPLEMENTATION.md)
- [Function Specifications](../specs/)
