
## 🚀 Prompt 1: Base Setup and Providers

ROLE: Act as a Senior Infrastructure Engineer and Terraform expert specializing in AWS and Infrastructure as Code best practices.


Create the base structure of a Terraform project to integrate AWS with Datadog monitoring.

CONTEXT: I'm starting a new Infrastructure as Code project to monitor AWS infrastructure with Datadog using Terraform.

GENERATE these files:

1. `provider.tf` with:
   - AWS provider ~> 5.0 with configurable region
   - Datadog provider ~> 3.0 with api_key and app_key from variables
   - Optional S3 backend (commented out)
   - Complete required_providers block

2. `variables.tf` with variables for:
   - datadog_api_key (sensitive)
   - datadog_app_key (sensitive) 
   - datadog_site (default "datadoghq.com")
   - aws_region (default "us-east-1")
   - environment (validation: dev/staging/prod)
   - project_name (default "aws-datadog-monitoring")
   - instance_type (default "t3.micro")

3. `versions.tf` with:
   - terraform >= 1.0
   - required_providers with specific versions

4. `terraform.tfvars.example` with example values

5. `.gitignore` for Terraform

REQUIREMENTS:
- Each variable must have description
- Use validation for environment
- Mark API keys as sensitive
- Comment each code section
- Modular and clean structure
- Follow Terraform best practices
 

---

## 🔐 Prompt 2: IAM Roles and Permissions


Create `iam.tf` file to configure IAM permissions necessary for Datadog-AWS integration.

CONTEXT: Datadog needs an IAM role with specific permissions to read CloudWatch metrics and EC2 information following AWS security best practices.

GENERATE:

1. Data source for current AWS account ID

2. IAM Role "DatadogIntegrationRole" with:
   - Trust policy for Datadog account (464622532012)
   - Random external ID for security
   - Standard tags (Environment, Project, Terraform)

3. IAM Policy "DatadogIntegrationPolicy" with permissions for:
   - cloudwatch:List*, cloudwatch:Get*
   - ec2:Describe* (instances, security-groups, tags)
   - autoscaling:Describe*
   - elasticloadbalancing:Describe*
   - rds:Describe*, rds:List*
   - lambda:List*, lambda:Get*
   - s3:GetBucketLocation, s3:ListBucket (only if needed)

4. Policy attachment to role

5. Outputs:
   - datadog_role_arn
   - external_id

SECURITY REQUIREMENTS:
- Follow least privilege principle
- Use conditions in policies where possible
- External ID to prevent confused deputy attacks
- Document each permission with comments
- Include resource-level restrictions where applicable


---

## 🔗 Prompt 3: Datadog Integration



Create `datadog-integration.tf` file to configure the integration between AWS and Datadog.

CONTEXT: I need to register the AWS account in Datadog using Terraform resources from the Datadog provider.

GENERATE:

1. Resource `datadog_integration_aws` with:
   - account_id from data source
   - role_name from IAM module
   - host_tags for environment and project
   - account_specific_namespace_rules for filtering
   - excluded_regions if necessary

2. Resource `datadog_integration_aws_lambda_arn` for:
   - IAM role ARN created previously
   - account_id linkage

3. Optional: `datadog_integration_aws_log_collection` for:
   - CloudWatch logs collection
   - services = ["lambda", "elb", "elbv2", "cloudfront", "redshift", "s3"]

4. Data source to verify existing integration

5. Locals for:
   - common_tags
   - integration_config

CONFIGURATION:
- auto_mute = true for terminated instances
- cspm_resource_collection_enabled = true
- metrics_collection_enabled = true  
- resource_collection_enabled = true
- Explicit depends_on for IAM role

OUTPUTS:
- integration_external_id
- aws_account_id

BEST PRACTICES:
- Error handling for integration conflicts
- Proper resource dependencies
- Documentation for each configuration option
```

---

## 🖥️ Prompt 4: EC2 Configuration

 
 
Create `ec2.tf` file to configure EC2 instances optimized for Datadog monitoring.

CONTEXT: I need to create EC2 instances that will be monitored by Datadog, with appropriate security groups and IAM roles.

GENERATE:

1. Data source for latest Amazon Linux 2 AMI

2. Security Group "datadog-monitoring-sg" with:
   - Ingress: SSH (22) from specific CIDR
   - Ingress: HTTP (80), HTTPS (443) from anywhere
   - Egress: HTTPS (443) to *.datadoghq.com, *.amazonaws.com
   - Egress: HTTP (80) for package installation
   - Standard tags

3. IAM Role for EC2 instances with policies for:
   - CloudWatchAgentServerPolicy (AWS managed)
   - AmazonSSMManagedInstanceCore (AWS managed)
   - Custom policy for Datadog agent

4. IAM Instance Profile linked to role

5. EC2 Instance resource with:
   - ami from data source
   - instance_type from variable
   - iam_instance_profile
   - vpc_security_group_ids
   - monitoring = true (detailed monitoring)
   - user_data = filebase64("scripts/user_data.sh") # placeholder
   - Tags: Name, Environment, Project, Service

6. Locals for:
   - common_tags
   - user_data template vars

OUTPUTS:
- instance_ids
- public_ips  
- private_ips
- security_group_id

SECURITY CONSIDERATIONS:
- Minimal required ports open
- Principle of least privilege for IAM
- Proper tagging for governance
 

---

## 📦 Prompt 5: User Data and Agent Installation
 
 
Create `scripts/` directory with `user_data.sh` file to automatically install Datadog agent on EC2.

CONTEXT: EC2 instances must have Datadog agent installed and configured automatically at boot time.

GENERATE:

1. `scripts/user_data.sh` for Amazon Linux 2 with:
   - Shebang and error handling (set -euo pipefail)
   - System update
   - Datadog agent installation via official script
   - Configuration of `/etc/datadog-agent/datadog.yaml` with:
     * api_key from template variable
     * site from template variable  
     * tags: environment, project, service, instance-id
     * hostname from EC2 metadata
     * log_level: info
   - Enable integrations:
     * system core checks
     * docker (if present)
     * process monitoring
   - Start and enable datadog-agent service

2. Template data for user_data in ec2.tf:
```hcl
locals {
  user_data = templatefile("scripts/user_data.sh", {
    datadog_api_key = var.datadog_api_key
    datadog_site    = var.datadog_site
    environment     = var.environment
    project_name    = var.project_name
  })
}
```

3. `scripts/cloudwatch_agent_config.json` for CloudWatch agent with:
   - Memory utilization metrics
   - Disk usage metrics  
   - Custom namespace
   - Detailed monitoring configuration

4. Update ec2.tf user_data with:
   - user_data = base64encode(local.user_data)

LOGGING AND VALIDATION:
- Installation output to /var/log/user-data.log
- Datadog agent logs in /var/log/datadog/
- Error handling for installation failures
- Post-installation health checks
- Retry mechanisms for network issues
 

---

## 📊 Prompt 6: Dashboard Creation

 

Create `datadog-dashboards.tf` file for comprehensive monitoring dashboards.

CONTEXT: I need to create Datadog dashboards to visualize AWS metrics and system metrics from EC2 instances.

GENERATE:

1. Dashboard "AWS Infrastructure Overview" with JSON layout containing:

WIDGET ROW 1 (Overview):
- Timeseries: aws.ec2.cpuutilization by instance
- Query value: Count of running instances
- Query value: Average system load

WIDGET ROW 2 (System Metrics):  
- Timeseries: system.cpu.user, system.cpu.system
- Timeseries: system.mem.pct_usable  
- Timeseries: system.disk.used_pct by device

WIDGET ROW 3 (Network & I/O):
- Timeseries: aws.ec2.network_in, aws.ec2.network_out
- Timeseries: system.io.rkb_s, system.io.wkb_s

2. Dashboard "Application Monitoring" with:
- Process monitoring widgets
- Docker container metrics (if applicable)
- Custom application metrics
- Log stream for errors

3. Configuration for each widget:
- Template variables for environment/service filtering
- Time range: past_1_hour default
- Auto-refresh every 5 minutes
- Proper titles and descriptions
- Appropriate Y-axis scaling

4. Locals for:
- Dashboard URLs
- Common widget configurations
- Standard color schemes

TEMPLATE VARIABLES:
- $environment with tag values
- $service with tag values  
- $instance with host values

OUTPUTS:
- dashboard_urls
- dashboard_ids

JSON STRUCTURE: Use proper indentation and formatting for readability
VISUALIZATION BEST PRACTICES: Include appropriate chart types, colors, and legends

---

## 🚨 Prompt 7: Monitoring and Alerts

**Use in Cursor for alerting system:**

```
ROLE: Act as a Site Reliability Engineer and monitoring specialist with expertise in proactive alerting, incident response, and Datadog monitor configuration for production environments.

Create `datadog-monitors.tf` file to configure proactive monitoring and alerting.

CONTEXT: I need to create Datadog monitors for automatic alerting on infrastructure issues.

GENERATE:

1. Monitor "High CPU Usage" with:
   - Type: metric alert
   - Query: avg CPU > 80% for 5 minutes
   - Thresholds: warning 70%, critical 85%
   - Message template with @slack and @email
   - No data timeout: 10 minutes
   - Tags for grouping

2. Monitor "High Memory Usage" with:
   - Query: system.mem.pct_usable < 20%
   - Thresholds: warning 30%, critical 15%
   - Include swap metrics if available

3. Monitor "Disk Space Critical" with:
   - Query: max disk usage > 90%
   - Per device/mount point
   - Exclude temporary filesystems

4. Monitor "Instance Down" with:
   - Query: aws.ec2.status_check_failed
   - Include system status check
   - Immediate alerting

5. Monitor "Datadog Agent Connectivity" with:
   - Query: datadog.agent.up
   - No data threshold: 10 minutes
   - Critical for agent disconnection

6. Notification channels:
   - Slack webhook integration
   - Email distribution list
   - PagerDuty for critical (optional)

CONFIGURATION FOR EACH MONITOR:
- include_tags = true
- require_full_window = false  
- new_host_delay = 300 seconds
- evaluation_delay = 60 seconds
- renotify_interval = 30 minutes

LOCALS:
- common_monitor_tags
- notification_channels
- escalation_messages

MESSAGE TEMPLATES:
- Include runbook links
- Playbook instructions
- Context variables: {{host.name}}, {{value}}

ALERTING BEST PRACTICES:
- Appropriate thresholds to avoid alert fatigue
- Clear escalation procedures
- Actionable alert messages
```

---

## 🧪 Prompt 8: Testing and Validation


Create `tests/` directory with scripts to validate the complete deployment.

CONTEXT: I need to verify that the AWS-Datadog integration works correctly after Terraform deployment.

GENERATE:

1. `tests/validate_deployment.sh` bash script with:
   - Check Datadog agent connectivity on instances
   - Verify metrics arriving at Datadog via API
   - Test dashboard population
   - Validate alert configuration
   - Check AWS-Datadog integration status

2. `tests/load_test.sh` to simulate:
   - High CPU usage (stress command)
   - High memory consumption
   - Disk space fill (temporary)
   - Verify that alerts trigger

3. `tests/terraform_validate.sh` with:
   - terraform fmt -check
   - terraform validate  
   - tflint checks
   - terraform plan -detailed-exitcode

4. `tests/datadog_api_test.py` Python script for:
   - Test API connectivity
   - Verify host reporting
   - Dashboard widget data validation
   - Monitor status check

5. `tests/cleanup.sh` for:
   - Stop load tests
   - Cleanup temporary files
   - Reset test conditions

REQUIREMENTS for Python script:
- requests library
- datadog-api-client
- Environment variables for API keys
- Error handling and logging

VALIDATION CHECKS:
- Appropriate exit codes (0 = success)
- Colored output for readability  
- Detailed logging in tests/logs/
- Summary report generation

OPTIONAL MAKEFILE for:
- make validate
- make test
- make cleanup
- make deploy

Include README.md in tests/ with instructions for using the scripts.

TESTING BEST PRACTICES:
- Comprehensive coverage of all components
- Clear pass/fail criteria
- Detailed error reporting
- Automated cleanup procedures
 
---

## 🚀 Prompt 9: Deployment Automation

 
Create scripts and documentation to automate complete deployment.

CONTEXT: I need to provide complete automation for deployment across different environments (dev/staging/prod).

GENERATE:

1. `deploy.sh` main script with:
   - Environment selection (dev/staging/prod)
   - Prerequisites check (terraform, aws cli, credentials)
   - Terraform init/plan/apply with approval
   - Post-deployment validation
   - Rollback capability

2. `Makefile` with targets:
   - init: terraform init for environment
   - plan: terraform plan with output file
   - apply: terraform apply with optional auto-approve  
   - destroy: terraform destroy with confirmation
   - validate: run all tests
   - clean: cleanup temporary files

3. `environments/` directory with:
   - `dev.tfvars`
   - `staging.tfvars`  
   - `prod.tfvars`
   - Separate files for each environment

4. Complete `README.md` with:
   - Prerequisites and setup
   - Step-by-step deployment guide
   - Troubleshooting common issues
   - Architecture overview
   - Cost estimation
   - Security considerations

5. `.github/workflows/terraform.yml` for CI/CD (optional):
   - Terraform plan on PR
   - Auto-apply on main merge
   - Multi-environment support
   - Security scanning

DEPLOY SCRIPT FEATURES:
- Color-coded output
- Progress indicators  
- Error handling and cleanup
- Backup current state
- Confirmation prompts
- Log all actions

ENVIRONMENT CONFIGURATIONS:
- Different instance types per env
- Different monitoring thresholds
- Tag variations
- Network configurations

DOCUMENTATION:
- Architecture diagrams (mermaid)
- Cost breakdown per environment
- Monitoring setup guide
- Operational runbooks

AUTOMATION BEST PRACTICES:
- Idempotent operations
- Comprehensive error handling
- Clear logging and reporting
- Environment isolation
- Security-first approach
```

---

## 📋 How to Use These Prompts in Cursor

### Initial Setup
1. Open Cursor in your editor
2. Create new project/directory for Terraform
3. Use **Prompt 1** to create base structure

### Sequential Workflow
1. **Prompt 1** → Base structure and providers
2. **Prompt 2** → IAM roles and permissions  
3. **Prompt 3** → Datadog integration
4. **Prompt 4** → EC2 configuration
5. **Prompt 5** → Agent installation scripts
6. **Prompt 6** → Dashboard creation
7. **Prompt 7** → Monitoring and alerts
8. **Prompt 8** → Testing and validation
9. **Prompt 9** → Deployment automation

### Cursor Tips
- **Use @workspace** for context on existing files
- **Select code** before prompt for specific modifications
- **Use Cmd+K** for quick edits
- **Chat panel** for follow-up questions
- **Apply** only after reviewing generated code

### Example Cursor Commands
```bash
# After each prompt, test the code:
terraform init
terraform validate  
terraform plan

# For incremental changes use:
@workspace "modify the security group in ec2.tf to add port 8080"

# For debugging use:
@workspace "why does terraform plan fail on this file?"
 

### Quality Assurance
- **Review each generated file** before proceeding
- **Test incrementally** with `terraform validate`
- **Use version control** to track changes
- **Document customizations** for your environment

 