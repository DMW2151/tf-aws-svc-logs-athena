
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/wafv2_web_acl 
resource "aws_wafv2_web_acl" "default" {

  // General
  name        = "rate-limit-canada"
  description = "Rate-Based ACL on all Canadian IPs"
  scope       = "REGIONAL"

  // Actions - Always Allow 
  default_action {
    allow {}
  }

  // Sample Rule to Block Traffic From Canada...
  // TODO: these rates are per 5-min (?)
  rule {
    name     = "rate-limit-canada"
    priority = 1

    action {
      block {}
    }

    // No more than 10 requests from a Canadian IP per K minutes...
    statement {

      rate_based_statement {
        limit              = 10
        aggregate_key_type = "IP"

        scope_down_statement {
          geo_match_statement {
            country_codes = ["CA"]
          }
        }

      }

    }

    // Metrics CloudWatch Configuration - Required Block - 
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "ca-block-waf-acl"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}


// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association
resource "aws_wafv2_web_acl_association" "example" {

  // General

  // NOTE: The Amazon Resource Name (ARN) of the resource to associate with the web ACL. This must be an ARN of an Application 
  // Load Balancer or an Amazon API Gateway stage.
  resource_arn = aws_api_gateway_stage.example.arn
  web_acl_arn  = aws_wafv2_web_acl.default.arn
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration
resource "aws_wafv2_web_acl_logging_configuration" "bucket" {

  // General
  resource_arn = aws_wafv2_web_acl.default.arn
  log_destination_configs = [
    aws_kinesis_firehose_delivery_stream.example.arn
  ]

  // Redact a sample field - Just to make sure this works
  redacted_fields {
    single_header {
      name = "user-agent"
    }
  }
}