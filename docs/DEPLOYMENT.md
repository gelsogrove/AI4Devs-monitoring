# LTI Recruiter Infrastructure Deployment Guide

This document provides instructions for deploying the infrastructure for the LTI Recruiter project.

## Infrastructure Components

The Terraform configuration creates the following resources:

1. **Amazon EC2 Instances**:
   - Backend instance (t2.micro) - Running on port 8080
   - Frontend instance (t2.micro) - Running on port 3000

2. **Amazon S3 Bucket**:
   - Stores `frontend.zip` and `backend.zip` files
   - Provides download access to EC2 instances

3. **IAM Roles and Policies**:
   - EC2 instance profile with permissions to access S3 bucket
   - S3 access policy for reading objects

4. **Security Groups**:
   - Backend security group (allows SSH and port 8080)
   - Frontend security group (allows SSH and port 3000)

## Deployment Steps

1. **Check Prerequisites**:
   - AWS CLI installed and configured
   - Terraform installed (v1.2.0+)
   - AWS credentials with appropriate permissions
   - Backend and frontend code in respective directories

2. **Generate ZIP Files**:
   - The script `generar-zip.sh` creates `backend.zip` and `frontend.zip`
   - These files are created from the backend/ and frontend/ directories

3. **Deploy Infrastructure**:
   ```bash
   # Initialize Terraform
   terraform init
   
   # Plan the deployment
   terraform plan
   
   # Apply the configuration
   terraform apply
   ```

4. **Post-Deployment**:
   - After successful deployment, Terraform outputs:
     - Backend URL (http://<backend_ip>:8080)
     - Frontend URL (http://<frontend_ip>:3000)
     - S3 bucket name

## Technical Details

### User Data Scripts

The EC2 instances use user data scripts to:
1. Install dependencies (Docker, AWS CLI, unzip)
2. Download the appropriate ZIP file from S3
3. Unzip the application code
4. Build and run Docker containers

### IAM Configuration

The IAM role gives EC2 instances the minimum permissions needed:
- `s3:GetObject` - To download ZIP files
- `s3:ListBucket` - To list bucket contents

### Security

- All instances use security groups limiting access to required ports
- S3 bucket is set to private access
- EC2 instances can only read from S3 (not write)

## Troubleshooting

If deployment fails due to permission errors:

1. **IAM Permissions**: Ensure your AWS user has these permissions:
   - `ec2:*`
   - `s3:*`
   - `iam:*`

2. **AWS Credentials**: Verify your AWS credentials are correctly configured:
   ```bash
   aws sts get-caller-identity
   ```

3. **Bucket Name**: If S3 bucket creation fails due to name conflicts, update the bucket name in `variables.tf`

4. **Zip Generation**: If ZIP files aren't generated correctly, check:
   - Do backend/ and frontend/ directories exist?
   - Run `./generar-zip.sh` manually to verify it works

## Cleanup

To remove all infrastructure components:

```bash
terraform destroy
```

This will delete all resources created by Terraform, including EC2 instances, S3 bucket, IAM roles, and security groups. 