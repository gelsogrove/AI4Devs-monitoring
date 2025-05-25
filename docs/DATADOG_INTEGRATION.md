# AWS-Datadog Integration Guide

This guide explains how to set up and use the AWS-Datadog integration to monitor your AWS infrastructure effectively.

## Prerequisites

1. **Datadog Account**: You need a Datadog account with Admin access
2. **AWS Account**: You need an AWS account with Admin access
3. **Terraform**: Version 1.0+ installed locally

## Setup Instructions

### 1. Create Datadog API and Application Keys

1. Log in to your Datadog account
2. Go to **Organization Settings** > **API Keys** and create a new API key
3. Go to **Organization Settings** > **Application Keys** and create a new Application key
4. Save both keys securely - you'll need them for the Terraform configuration

### 2. Configure Terraform Variables

1. Copy the example variables file:
   ```bash
   cp tf/terraform.tfvars.example tf/terraform.tfvars
   ```

2. Edit `tf/terraform.tfvars` and add your Datadog API and Application keys:
   ```hcl
   datadog_api_key = "your_api_key_here"
   datadog_app_key = "your_application_key_here"
   datadog_site    = "datadoghq.com" # Use datadoghq.eu for EU sites
   ```

### 3. Deploy the Integration

1. Initialize Terraform:
   ```bash
   cd tf
   terraform init
   ```

2. Review the Terraform plan:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Confirm the deployment by checking the outputs:
   ```bash
   terraform output
   ```

### 4. Verify the Integration

1. Log in to your Datadog account
2. Go to **Integrations** > **AWS**
3. Verify that your AWS account is listed and the status is "Connected"
4. Navigate to **Infrastructure** > **Infrastructure List** to see your AWS resources
5. Check out the **AWS Dashboard** to visualize your metrics

## Features Provided by the Integration

### Metrics Collection

The integration collects metrics from the following AWS services:

- EC2 (CPU, disk, network, etc.)
- ELB/ALB/NLB (request counts, latency, etc.)
- RDS (database performance metrics)
- Lambda (invocations, errors, duration)
- S3 (bucket size, request counts)
- CloudFront (requests, errors, latency)
- Many other AWS services

### CloudTrail Events

The integration collects CloudTrail events and shows them in the Datadog Events Explorer, allowing you to:

- Track API calls and changes in your AWS environment
- Correlate infrastructure changes with application performance
- Identify security issues or policy violations

### AWS Tags

AWS resource tags are automatically pulled into Datadog, enabling you to:

- Group and filter metrics by AWS tags
- Create dashboards based on tag values
- Set up monitors with tag-based alerting

### Log Collection

The integration can collect logs from various AWS services:

- Lambda function logs
- ELB/ALB access logs
- CloudFront logs
- S3 access logs
- RDS logs

## Dashboard and Monitoring

### AWS Dashboard

The integration includes a comprehensive AWS dashboard that displays:

- EC2 instance metrics
- Lambda function performance
- API Gateway metrics
- RDS database performance
- S3 bucket utilization
- SQS queue metrics

### Monitors

The integration sets up several critical monitors:

- EC2 high CPU utilization
- Lambda error rates
- EC2 status check failures
- RDS high CPU and low storage
- Application load balancer high latency and error rates

## Troubleshooting

### Common Issues

1. **Integration Not Working**: Verify IAM permissions are correctly set up
2. **Missing Metrics**: Check that the service namespaces are enabled in the integration
3. **No Logs**: Verify that the log forwarder is properly configured

### Getting Help

- Review the [Datadog AWS Integration Documentation](https://docs.datadoghq.com/integrations/amazon_web_services/)
- Contact [Datadog Support](https://www.datadoghq.com/support/) for assistance

## Maintenance

### Updating the Integration

To update the integration configuration:

1. Make changes to the Terraform files
2. Run `terraform plan` to review changes
3. Run `terraform apply` to apply the changes

### Adding New AWS Services

To monitor new AWS services:

1. Update the IAM policy in `tf/iam.tf` to include permissions for the new service
2. Modify the namespace configuration in `tf/datadog_integration.tf`
3. Apply the changes with Terraform

## Security Considerations

- The IAM role uses the principle of least privilege
- External ID is used to prevent confused deputy attacks
- Datadog API and Application keys should be kept secure and rotated regularly

## Additional Resources

- [Datadog AWS Integration Documentation](https://docs.datadoghq.com/integrations/amazon_web_services/)
- [AWS IAM Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)
- [Terraform Datadog Provider Documentation](https://registry.terraform.io/providers/DataDog/datadog/latest/docs) 