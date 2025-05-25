# AMI Migration Guide: From Hardcoded IDs to Data Sources

## Current State
The infrastructure currently uses a hardcoded AMI ID in the `variables.tf` file:
```
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-075d39ebbca89ed55" # Amazon Linux 2 AMI
}
```

## Latest AMI IDs (as of current date)
- Latest Amazon Linux 2 AMI: `ami-09f4814ae750baed6`
- Latest Amazon Linux 2023 AMI: `ami-068380189371e0672`

## Migration Steps

### 1. Update variables.tf

```hcl
variable "use_al2023" {
  description = "Whether to use Amazon Linux 2023 instead of Amazon Linux 2"
  type        = bool
  default     = true
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (override automatic AMI selection)"
  type        = string
  default     = null
}
```

### 2. Create ami_data.tf

```hcl
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
```

### 3. Update ec2.tf

```hcl
locals {
  selected_ami = var.ami_id != null ? var.ami_id : (var.use_al2023 ? data.aws_ami.amazon_linux_2023.id : data.aws_ami.amazon_linux_2.id)
}

resource "aws_instance" "backend" {
  ami                    = local.selected_ami
  # other configurations remain unchanged
}

resource "aws_instance" "frontend" {
  ami                    = local.selected_ami
  # other configurations remain unchanged
}
```

## Benefits

- **Automatic Updates**: Always use the latest AMI without manual changes
- **Flexibility**: Choose between Amazon Linux 2 and Amazon Linux 2023
- **Override Option**: Still able to specify a specific AMI ID if needed

## Implementation Options

1. **Full Migration**: Replace hardcoded AMI IDs with data sources (recommended)
2. **Incremental Migration**: Start with reporting only, then move to using the data sources in a future update

## Testing

Before applying to production:
1. Run `terraform plan` to see what changes would be made
2. Validate that the correct AMIs are being selected
3. Consider testing in a development environment first 