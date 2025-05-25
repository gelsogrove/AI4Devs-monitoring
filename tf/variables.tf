variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "use_al2023" {
  description = "Whether to use Amazon Linux 2023 instead of Amazon Linux 2"
  type        = bool
  default     = true
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-075d39ebbca89ed55" # Amazon Linux 2 AMI
}

variable "bucket_name" {
  description = "S3 bucket name for code storage"
  type        = string
  default     = "lti-recruiter-code-bucket-unique"  # Use a unique name
}
