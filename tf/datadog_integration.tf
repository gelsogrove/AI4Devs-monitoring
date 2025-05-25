# Configure AWS-Datadog integration
resource "datadog_integration_aws_account" "main" {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_partition = "aws"
  
  aws_regions {
    include_all = true
  }
  
  auth_config {
    aws_auth_config_role {
      role_name = aws_iam_role.datadog_integration_role.name
      external_id = random_string.datadog_external_id.result
    }
  }
  
  resources_config {
    cloud_security_posture_management_collection = true
    extended_collection = true
  }
  
  metrics_config {
    namespace_filters {
      # Enable all namespaces by default
    }
  }
  
  logs_config {
    lambda_forwarder {
      # Empty block is required
    }
  }
  
  traces_config {
    xray_services {
      # Empty block is required
    }
  }
  
  # Wait for the IAM role to be ready
  depends_on = [aws_iam_role_policy_attachment.datadog_policy_attachment]
}

# Define locals for common tags and configuration
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
} 