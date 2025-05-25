terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

provider "aws" {}

provider "datadog" {
  api_key = "644b1aa9e093ab067228c799e88837cc"
  app_key = "264f2b6f6265892c1b30033848a8d7ec128289a6"
  validate = false
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "datadog_aws_integration_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::464622532012:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        "FVvWwgjFfQRckOAnRugR4OPLuRgOU1fD"  # Using our existing external ID
      ]
    }
  }
}

data "aws_iam_policy_document" "datadog_aws_integration" {
  statement {
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "ec2:Describe*",
      "ec2:Get*",
      "lambda:List*",
      "rds:Describe*",
      "rds:List*",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketTagging",
      "s3:ListAllMyBuckets",
      "s3:PutBucketNotification"
    ] 
    resources = ["*"]
  }
}

resource "aws_iam_policy" "datadog_aws_integration" {
  name   = "DatadogAWSIntegrationPolicy"
  policy = data.aws_iam_policy_document.datadog_aws_integration.json
}

resource "aws_iam_role" "datadog_aws_integration" {
  name               = "DatadogIntegrationRole"
  description        = "Role for Datadog AWS Integration"
  assume_role_policy = data.aws_iam_policy_document.datadog_aws_integration_assume_role.json
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role       = aws_iam_role.datadog_aws_integration.name
  policy_arn = aws_iam_policy.datadog_aws_integration.arn
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration_security_audit" {
  role       = aws_iam_role.datadog_aws_integration.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "datadog_role_name" {
  value = aws_iam_role.datadog_aws_integration.name
}

output "external_id" {
  value = "FVvWwgjFfQRckOAnRugR4OPLuRgOU1fD"  # Using our existing external ID
} 