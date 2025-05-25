/*
# EC2 CPU utilization monitor
resource "datadog_monitor" "ec2_cpu" {
  name               = "[EC2][${var.environment}] High CPU Utilization"
  type               = "metric alert"
  message            = "EC2 instance(s) CPU utilization is too high. Running at {{value}}% for the last 10 minutes.\n\nPlease investigate: {{host.name}}\n\n@slack-alerts"
  escalation_message = "EC2 instance(s) still experiencing high CPU! Please investigate immediately!"
  
  query = "avg(last_10m):avg:aws.ec2.cpuutilization{environment:${var.environment}} by {host} > 80"
  
  monitor_thresholds {
    warning  = 70
    critical = 80
  }
  
  notify_no_data    = false
  renotify_interval = 30
  
  include_tags = true
  
  tags = ["env:${var.environment}", "service:ec2", "terraform:true", "project:${var.project_name}"]
}

# EC2 Memory utilization monitor
resource "datadog_monitor" "ec2_memory" {
  name               = "[EC2][${var.environment}] High Memory Utilization"
  type               = "metric alert"
  message            = "EC2 instance(s) memory utilization is too high. Running at {{value}}% for the last 10 minutes.\n\nPlease investigate: {{host.name}}\n\n@slack-alerts"
  escalation_message = "EC2 instance(s) still experiencing high memory usage! Please investigate immediately!"
  
  query = "avg(last_10m):avg:system.mem.used{environment:${var.environment}} by {host} / avg:system.mem.total{environment:${var.environment}} by {host} * 100 > 85"
  
  monitor_thresholds {
    warning  = 75
    critical = 85
  }
  
  notify_no_data    = false
  renotify_interval = 30
  
  include_tags = true
  
  tags = ["env:${var.environment}", "service:ec2", "terraform:true", "project:${var.project_name}"]
}

# EC2 Disk usage monitor
resource "datadog_monitor" "ec2_disk" {
  name               = "[EC2][${var.environment}] High Disk Usage"
  type               = "metric alert"
  message            = "EC2 instance(s) disk usage is too high. Running at {{value}}% for the last 15 minutes.\n\nPlease investigate: {{host.name}}\n\n@slack-alerts"
  escalation_message = "EC2 instance(s) still experiencing high disk usage! Please investigate immediately!"
  
  query = "avg(last_15m):avg:system.disk.in_use{environment:${var.environment}} by {host,device} * 100 > 85"
  
  monitor_thresholds {
    warning  = 75
    critical = 85
  }
  
  notify_no_data    = false
  renotify_interval = 60
  
  include_tags = true
  
  tags = ["env:${var.environment}", "service:ec2", "terraform:true", "project:${var.project_name}"]
}

# Lambda error rate monitor
resource "datadog_monitor" "lambda_errors" {
  name               = "[Lambda][${var.environment}] High Error Rate"
  type               = "metric alert"
  message            = "Lambda function(s) error rate is too high. Error rate at {{value}}% for the last 10 minutes.\n\nPlease investigate: {{functionname.name}}\n\n@slack-alerts"
  escalation_message = "Lambda function(s) still experiencing high error rate! Please investigate immediately!"
  
  query = "sum(last_10m):sum:aws.lambda.errors{environment:${var.environment}} by {functionname}.as_count() / sum:aws.lambda.invocations{environment:${var.environment}} by {functionname}.as_count() * 100 > 5"
  
  monitor_thresholds {
    warning  = 2
    critical = 5
  }
  
  notify_no_data    = false
  renotify_interval = 30
  
  include_tags = true
  
  tags = ["env:${var.environment}", "service:lambda", "terraform:true", "project:${var.project_name}"]
}

# S3 bucket size monitor
resource "datadog_monitor" "s3_size" {
  name               = "[S3][${var.environment}] Large Bucket Size"
  type               = "metric alert"
  message            = "S3 bucket size has exceeded threshold. Current size is {{value}} GB.\n\nPlease investigate: {{bucketname.name}}\n\n@slack-alerts"
  
  query = "avg(last_1d):avg:aws.s3.bucket_size_bytes{environment:${var.environment}} by {bucketname} / 1000000000 > 5000"
  
  monitor_thresholds {
    warning  = 2000
    critical = 5000
  }
  
  notify_no_data    = false
  renotify_interval = 0  # Daily check, no need for frequent renotifications
  
  include_tags = true
  
  tags = ["env:${var.environment}", "service:s3", "terraform:true", "project:${var.project_name}"]
}

# API Gateway 5xx errors monitor
resource "datadog_monitor" "api_gateway_5xx" {
  name               = "[API Gateway][${var.environment}] High 5xx Error Rate"
  type               = "metric alert"
  message            = "API Gateway 5xx error rate is too high. Error rate at {{value}}% for the last 5 minutes.\n\nPlease investigate: {{apiname.name}}\n\n@slack-alerts"
  escalation_message = "API Gateway still experiencing high 5xx error rate! Please investigate immediately!"
  
  query = "sum(last_5m):sum:aws.apigateway.5xxerror{environment:${var.environment}} by {apiname}.as_count() / sum:aws.apigateway.count{environment:${var.environment}} by {apiname}.as_count() * 100 > 2"
  
  monitor_thresholds {
    warning  = 1
    critical = 2
  }
  
  notify_no_data    = false
  renotify_interval = 15
  
  include_tags = true
  
  tags = ["env:${var.environment}", "service:apigateway", "terraform:true", "project:${var.project_name}"]
}

# RDS CPU utilization monitor
resource "datadog_monitor" "rds_cpu" {
  name               = "[RDS][${var.environment}] High CPU Utilization"
  type               = "metric alert"
  message            = "RDS instance(s) CPU utilization is too high. Running at {{value}}% for the last 15 minutes.\n\nPlease investigate: {{dbinstanceidentifier.name}}\n\n@slack-alerts"
  escalation_message = "RDS instance(s) still experiencing high CPU! Please investigate immediately!"
  
  query = "avg(last_15m):avg:aws.rds.cpuutilization{environment:${var.environment}} by {dbinstanceidentifier} > 80"
  
  monitor_thresholds {
    warning  = 70
    critical = 80
  }
  
  notify_no_data    = false
  renotify_interval = 30
  
  include_tags = true
  
  tags = ["env:${var.environment}", "service:rds", "terraform:true", "project:${var.project_name}"]
}

# SQS message age monitor
resource "datadog_monitor" "sqs_age" {
  name               = "[SQS][${var.environment}] High Message Age"
  type               = "metric alert"
  message            = "SQS queue message age is too high. Current age is {{value}} seconds.\n\nPlease investigate: {{queuename.name}}\n\n@slack-alerts"
  
  query = "max(last_15m):max:aws.sqs.approximate_age_of_oldest_message{environment:${var.environment}} by {queuename} > 300"
  
  monitor_thresholds {
    warning  = 180
    critical = 300
  }
  
  notify_no_data    = false
  renotify_interval = 30
  
  include_tags = true
  
  tags = ["env:${var.environment}", "service:sqs", "terraform:true", "project:${var.project_name}"]
} 
*/ 