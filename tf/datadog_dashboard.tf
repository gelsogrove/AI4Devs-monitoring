# Main AWS Infrastructure Dashboard
# Commented out to avoid authentication errors during development
/*
resource "datadog_dashboard" "aws_overview" {
  title         = "AWS Infrastructure Overview - ${var.environment}"
  description   = "Overview of AWS infrastructure metrics for the ${var.environment} environment"
  layout_type   = "ordered"
  is_read_only  = false
  
  widget {
    group_definition {
      title = "EC2 Instances"
      layout_type = "ordered"
      
      widget {
        timeseries_definition {
          title = "EC2 CPU Utilization"
          request {
            q    = "avg:aws.ec2.cpuutilization{environment:${var.environment}} by {host}"
            display_type = "line"
          }
          yaxis {
            max = "100"
            min = "0"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "EC2 Memory Utilization"
          request {
            q    = "avg:system.mem.used{environment:${var.environment}} by {host} / avg:system.mem.total{environment:${var.environment}} by {host} * 100"
            display_type = "line"
          }
          yaxis {
            max = "100"
            min = "0"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "EC2 Disk Usage"
          request {
            q    = "avg:system.disk.in_use{environment:${var.environment}} by {host,device} * 100"
            display_type = "line"
          }
          yaxis {
            max = "100"
            min = "0"
          }
        }
      }
      
      widget {
        toplist_definition {
          title = "Top EC2 Instances by CPU"
          request {
            q = "top(avg:aws.ec2.cpuutilization{environment:${var.environment}} by {host}, 10, 'mean', 'desc')"
          }
        }
      }
    }
  }
  
  widget {
    group_definition {
      title = "Lambda Functions"
      layout_type = "ordered"
      
      widget {
        timeseries_definition {
          title = "Lambda Invocations"
          request {
            q    = "sum:aws.lambda.invocations{environment:${var.environment}} by {functionname}.as_count()"
            display_type = "bars"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "Lambda Errors"
          request {
            q    = "sum:aws.lambda.errors{environment:${var.environment}} by {functionname}.as_count()"
            display_type = "bars"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "Lambda Duration"
          request {
            q    = "avg:aws.lambda.duration{environment:${var.environment}} by {functionname}"
            display_type = "line"
          }
        }
      }
      
      widget {
        toplist_definition {
          title = "Top Lambda Functions by Error Rate"
          request {
            q = "top(sum:aws.lambda.errors{environment:${var.environment}} by {functionname}.as_count() / sum:aws.lambda.invocations{environment:${var.environment}} by {functionname}.as_count() * 100, 10, 'mean', 'desc')"
          }
        }
      }
    }
  }
  
  widget {
    group_definition {
      title = "API Gateway"
      layout_type = "ordered"
      
      widget {
        timeseries_definition {
          title = "API Requests"
          request {
            q    = "sum:aws.apigateway.count{environment:${var.environment}} by {apiname}.as_count()"
            display_type = "bars"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "API Gateway Latency"
          request {
            q    = "avg:aws.apigateway.latency{environment:${var.environment}} by {apiname}"
            display_type = "line"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "API Gateway 4xx Errors"
          request {
            q    = "sum:aws.apigateway.4xxerror{environment:${var.environment}} by {apiname}.as_count()"
            display_type = "bars"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "API Gateway 5xx Errors"
          request {
            q    = "sum:aws.apigateway.5xxerror{environment:${var.environment}} by {apiname}.as_count()"
            display_type = "bars"
          }
        }
      }
    }
  }
  
  widget {
    group_definition {
      title = "RDS"
      layout_type = "ordered"
      
      widget {
        timeseries_definition {
          title = "RDS CPU Utilization"
          request {
            q    = "avg:aws.rds.cpuutilization{environment:${var.environment}} by {dbinstanceidentifier}"
            display_type = "line"
          }
          yaxis {
            max = "100"
            min = "0"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "RDS Free Storage Space"
          request {
            q    = "avg:aws.rds.free_storage_space{environment:${var.environment}} by {dbinstanceidentifier}"
            display_type = "line"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "RDS Database Connections"
          request {
            q    = "avg:aws.rds.database_connections{environment:${var.environment}} by {dbinstanceidentifier}"
            display_type = "line"
          }
        }
      }
    }
  }
  
  widget {
    group_definition {
      title = "S3 Buckets"
      layout_type = "ordered"
      
      widget {
        timeseries_definition {
          title = "S3 Bucket Size"
          request {
            q    = "avg:aws.s3.bucket_size_bytes{environment:${var.environment}} by {bucketname} / 1000000000"
            display_type = "line"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "S3 Number of Objects"
          request {
            q    = "avg:aws.s3.number_of_objects{environment:${var.environment}} by {bucketname}"
            display_type = "line"
          }
        }
      }
    }
  }
  
  widget {
    group_definition {
      title = "SQS Queues"
      layout_type = "ordered"
      
      widget {
        timeseries_definition {
          title = "SQS Messages Visible"
          request {
            q    = "avg:aws.sqs.approximate_number_of_messages_visible{environment:${var.environment}} by {queuename}"
            display_type = "line"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "SQS Messages Delayed"
          request {
            q    = "avg:aws.sqs.approximate_number_of_messages_delayed{environment:${var.environment}} by {queuename}"
            display_type = "line"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "SQS Oldest Message Age"
          request {
            q    = "max:aws.sqs.approximate_age_of_oldest_message{environment:${var.environment}} by {queuename}"
            display_type = "line"
          }
        }
      }
    }
  }
  
  # Common tags for all dashboard elements
  widget {
    note_definition {
      content  = "Dashboard created by Terraform for ${var.project_name} - ${var.environment} environment"
      show_tick = true
      tick_pos = "bottom"
      tick_edge = "bottom"
      background_color = "green"
      font_size = "14"
      text_align = "center"
    }
  }
}
*/ 