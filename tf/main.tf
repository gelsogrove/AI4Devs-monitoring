terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  
  # Uncomment this block to use an S3 backend for state storage
  # backend "s3" {
  #   bucket         = "terraform-state-bucket-name"
  #   key            = "aws-datadog-monitoring/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-lock-table"
  # }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Configure the Datadog Provider
provider "datadog" {
  api_key = "644b1aa9e093ab067228c799e88837cc"
  app_key = "e108d9a6e9f597a68c8adaa43911afd0b8843b62"
  validate = false
}

# Provider configuration for random
provider "random" {
  # No configuration needed for the random provider
}

# Outputs for easy access to resources
output "backend_public_ip" {
  value       = aws_instance.backend.public_ip
  description = "The public IP of the backend instance"
}

output "backend_url" {
  value       = "http://${aws_instance.backend.public_ip}:8080"
  description = "The URL to access the backend application"
}

output "frontend_public_ip" {
  value       = aws_instance.frontend.public_ip
  description = "The public IP of the frontend instance"
}

output "frontend_url" {
  value       = "http://${aws_instance.frontend.public_ip}:3000"
  description = "The URL to access the frontend application"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.code_bucket.bucket
  description = "The name of the S3 bucket storing the application code"
}

output "aws_account_number" {
  value       = data.aws_caller_identity.current.account_id
  description = "The AWS account number"
}

output "datadog_aws_role_name" {
  value       = aws_iam_role.datadog_integration_role.name
  description = "The name of the IAM role for Datadog integration"
}

output "datadog_integration_setup_instructions" {
  value = <<EOT
To set up the Datadog AWS integration manually:
    
1. Log in to your Datadog account
2. Go to Integrations > AWS
3. Click on "Add an AWS Account" 
4. Use the following values:
   - AWS Account ID: ${data.aws_caller_identity.current.account_id}
   - Role Name: ${aws_iam_role.datadog_integration_role.name}
   - External ID: ${random_string.datadog_external_id.result}
    
For more detailed instructions, refer to the docs/DATADOG_INTEGRATION.md file.

EOT
  description = "Instructions for setting up the Datadog AWS integration"
}
