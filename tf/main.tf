terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
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

# New outputs for AMI information
output "current_instance_ami" {
  value       = aws_instance.backend.ami
  description = "The current AMI ID used by the instances"
}

output "amazon_linux_2_latest_ami" {
  value       = data.aws_ami.amazon_linux_2.id
  description = "The latest Amazon Linux 2 AMI ID"
}

output "amazon_linux_2023_latest_ami" {
  value       = data.aws_ami.amazon_linux_2023.id
  description = "The latest Amazon Linux 2023 AMI ID"
}
