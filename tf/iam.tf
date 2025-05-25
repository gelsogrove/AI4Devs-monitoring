data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.code_bucket.arn,
      "${aws_s3_bucket.code_bucket.arn}/*"
    ]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name   = "lti-recruiter-s3-access-policy"
  policy = data.aws_iam_policy_document.s3_access_policy.json
}

resource "aws_iam_role" "ec2_role" {
  name               = "lti-recruiter-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_s3_access_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "lti-recruiter-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Random string for external ID (security best practice)
resource "random_string" "datadog_external_id" {
  length  = 32
  special = false
}

# IAM Role for Datadog Integration
resource "aws_iam_role" "datadog_integration_role" {
  name = "DatadogIntegrationRole"

  # Trust policy to allow Datadog to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::464622532012:root" # Datadog's AWS account ID
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = random_string.datadog_external_id.result
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

# IAM Policy for Datadog Integration
resource "aws_iam_policy" "datadog_integration_policy" {
  name        = "DatadogIntegrationPolicy"
  description = "Policy allowing Datadog to collect metrics and metadata from AWS services"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "apigateway:GET",
          "aoss:BatchGetCollection",
          "aoss:ListCollections",
          "autoscaling:Describe*",
          "backup:List*",
          "bcm-data-exports:GetExport",
          "bcm-data-exports:ListExports",
          "bedrock:GetAgent",
          "bedrock:GetAgentAlias",
          "bedrock:GetFlow",
          "bedrock:GetFlowAlias",
          "bedrock:GetGuardrail",
          "bedrock:GetImportedModel",
          "bedrock:GetInferenceProfile",
          "bedrock:GetMarketplaceModelEndpoint",
          "bedrock:ListAgentAliases",
          "bedrock:ListAgents",
          "bedrock:ListFlowAliases",
          "bedrock:ListFlows",
          "bedrock:ListGuardrails",
          "bedrock:ListImportedModels",
          "bedrock:ListInferenceProfiles",
          "bedrock:ListMarketplaceModelEndpoints",
          "bedrock:ListPromptRouters",
          "bedrock:ListProvisionedModelThroughputs",
          "budgets:ViewBudget",
          "cassandra:Select",
          "cloudfront:GetDistributionConfig",
          "cloudfront:ListDistributions",
          "cloudtrail:DescribeTrails",
          "cloudtrail:GetTrailStatus",
          "cloudtrail:LookupEvents",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "codeartifact:DescribeDomain",
          "codeartifact:DescribePackageGroup",
          "codeartifact:DescribeRepository",
          "codeartifact:ListDomains",
          "codeartifact:ListPackageGroups",
          "codeartifact:ListPackages",
          "codedeploy:BatchGet*",
          "codedeploy:List*",
          "codepipeline:ListWebhooks",
          "cur:DescribeReportDefinitions",
          "directconnect:Describe*",
          "dynamodb:Describe*",
          "dynamodb:List*",
          "ec2:Describe*",
          "ec2:GetAllowedImagesSettings",
          "ec2:GetEbsDefaultKmsKeyId",
          "ec2:GetInstanceMetadataDefaults",
          "ec2:GetSerialConsoleAccessStatus",
          "ec2:GetSnapshotBlockPublicAccessState",
          "ec2:GetTransitGatewayPrefixListReferences",
          "ec2:SearchTransitGatewayRoutes",
          "ecs:Describe*",
          "ecs:List*",
          "elasticache:Describe*",
          "elasticache:List*",
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeTags",
          "elasticloadbalancing:Describe*",
          "elasticmapreduce:Describe*",
          "elasticmapreduce:List*",
          "emr-containers:ListManagedEndpoints",
          "emr-containers:ListSecurityConfigurations",
          "emr-containers:ListVirtualClusters",
          "es:DescribeElasticsearchDomains",
          "es:ListDomainNames",
          "es:ListTags",
          "events:CreateEventBus",
          "fsx:DescribeFileSystems",
          "fsx:ListTagsForResource",
          "glacier:GetVaultNotifications",
          "glue:ListRegistries",
          "grafana:DescribeWorkspace",
          "greengrass:GetComponent",
          "greengrass:GetConnectivityInfo",
          "greengrass:GetCoreDevice",
          "greengrass:GetDeployment",
          "health:DescribeAffectedEntities",
          "health:DescribeEventDetails",
          "health:DescribeEvents",
          "kinesis:Describe*",
          "kinesis:List*",
          "lambda:GetPolicy",
          "lambda:List*",
          "lightsail:GetInstancePortStates",
          "logs:DeleteSubscriptionFilter",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:DescribeSubscriptionFilters",
          "logs:FilterLogEvents",
          "logs:PutSubscriptionFilter",
          "logs:TestMetricFilter",
          "macie2:GetAllowList",
          "macie2:GetCustomDataIdentifier",
          "macie2:ListAllowLists",
          "macie2:ListCustomDataIdentifiers",
          "macie2:ListMembers",
          "macie2:GetMacieSession",
          "managedblockchain:GetAccessor",
          "managedblockchain:GetMember",
          "managedblockchain:GetNetwork",
          "managedblockchain:GetNode",
          "managedblockchain:GetProposal",
          "managedblockchain:ListAccessors",
          "managedblockchain:ListInvitations",
          "managedblockchain:ListMembers",
          "managedblockchain:ListNodes",
          "managedblockchain:ListProposals",
          "memorydb:DescribeAcls",
          "memorydb:DescribeMultiRegionClusters",
          "memorydb:DescribeParameterGroups",
          "memorydb:DescribeReservedNodes",
          "memorydb:DescribeSnapshots",
          "memorydb:DescribeSubnetGroups",
          "memorydb:DescribeUsers",
          "oam:ListAttachedLinks",
          "oam:ListSinks",
          "organizations:Describe*",
          "organizations:List*",
          "osis:GetPipeline",
          "osis:GetPipelineBlueprint",
          "osis:ListPipelineBlueprints",
          "osis:ListPipelines",
          "proton:GetComponent",
          "proton:GetDeployment",
          "proton:GetEnvironment",
          "proton:GetEnvironmentAccountConnection",
          "proton:GetEnvironmentTemplate",
          "proton:GetEnvironmentTemplateVersion",
          "proton:GetRepository",
          "proton:GetService",
          "proton:GetServiceInstance",
          "proton:GetServiceTemplate",
          "proton:GetServiceTemplateVersion",
          "proton:ListComponents",
          "proton:ListDeployments",
          "proton:ListEnvironmentAccountConnections",
          "proton:ListEnvironmentTemplateVersions",
          "proton:ListEnvironmentTemplates",
          "proton:ListEnvironments",
          "proton:ListRepositories",
          "proton:ListServiceInstances",
          "proton:ListServiceTemplateVersions",
          "proton:ListServiceTemplates",
          "proton:ListServices",
          "qldb:ListJournalKinesisStreamsForLedger",
          "rds:Describe*",
          "rds:List*",
          "redshift:DescribeClusters",
          "redshift:DescribeLoggingStatus",
          "redshift-serverless:ListEndpointAccess",
          "redshift-serverless:ListManagedWorkgroups",
          "redshift-serverless:ListNamespaces",
          "redshift-serverless:ListRecoveryPoints",
          "redshift-serverless:ListSnapshots",
          "route53:List*",
          "s3:GetBucketLocation",
          "s3:GetBucketLogging",
          "s3:GetBucketNotification",
          "s3:GetBucketTagging",
          "s3:ListAccessGrants",
          "s3:ListAllMyBuckets",
          "s3:PutBucketNotification",
          "s3express:GetBucketPolicy",
          "s3express:GetEncryptionConfiguration",
          "s3express:ListAllMyDirectoryBuckets",
          "s3tables:GetTableBucketMaintenanceConfiguration",
          "s3tables:ListTableBuckets",
          "s3tables:ListTables",
          "savingsplans:DescribeSavingsPlanRates",
          "savingsplans:DescribeSavingsPlans",
          "secretsmanager:GetResourcePolicy",
          "ses:Get*",
          "ses:ListAddonInstances",
          "ses:ListAddonSubscriptions",
          "ses:ListAddressLists",
          "ses:ListArchives",
          "ses:ListContactLists",
          "ses:ListCustomVerificationEmailTemplates",
          "ses:ListMultiRegionEndpoints",
          "ses:ListIngressPoints",
          "ses:ListRelays",
          "ses:ListRuleSets",
          "ses:ListTemplates",
          "ses:ListTrafficPolicies",
          "sns:GetSubscriptionAttributes",
          "sns:List*",
          "sns:Publish",
          "sqs:ListQueues",
          "states:DescribeStateMachine",
          "states:ListStateMachines",
          "support:DescribeTrustedAdvisor*",
          "support:RefreshTrustedAdvisorCheck",
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues",
          "timestream:DescribeEndpoints",
          "timestream:ListTables",
          "waf-regional:GetRule",
          "waf-regional:GetRuleGroup",
          "waf-regional:ListRuleGroups",
          "waf-regional:ListRules",
          "waf:GetRule",
          "waf:GetRuleGroup",
          "waf:ListRuleGroups",
          "waf:ListRules",
          "wafv2:GetIPSet",
          "wafv2:GetLoggingConfiguration",
          "wafv2:GetRegexPatternSet",
          "wafv2:GetRuleGroup",
          "wafv2:ListLoggingConfigurations",
          "workmail:DescribeOrganization",
          "workmail:ListOrganizations",
          "xray:BatchGetTraces",
          "xray:GetTraceSummaries"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "datadog_policy_attachment" {
  role       = aws_iam_role.datadog_integration_role.name
  policy_arn = aws_iam_policy.datadog_integration_policy.arn
}

# Attach AWS SecurityAudit managed policy to the Datadog integration role
resource "aws_iam_role_policy_attachment" "datadog_aws_integration_security_audit" {
  role       = aws_iam_role.datadog_integration_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

# Outputs
output "datadog_integration_role_arn" {
  description = "ARN of the IAM role for Datadog integration"
  value       = aws_iam_role.datadog_integration_role.arn
}

output "datadog_integration_external_id" {
  description = "External ID for secure Datadog role assumption"
  value       = random_string.datadog_external_id.result
  sensitive   = true
}
