// Creates a dummy WAF rule 


// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/wafv2_web_acl 
resource "aws_wafv2_web_acl" "default" {

  // General
  name        = "rate-limit-us"
  description = "Rate-Based ACL on all US IPs"
  scope       = "REGIONAL"

  // Actions - Always Allow 
  default_action {
    allow {}
  }

  // Sample rule to block traffic from USA after 100 requests in 5 min.
  rule {
    name     = "rate-limit-us"
    priority = 1

    action {
      block {}
    }

    statement {

      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"

        scope_down_statement {
          geo_match_statement {
            country_codes = ["US"]
          }
        }

      }
    }

    // Metrics CloudWatch Configuration - No need for Cloudwatch, but need to set these values
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "tf-svc-logs-usa-block-waf-acl"
      sampled_requests_enabled   = false
    }
  }

  // Tags
  tags = {
    Name = "tf-svc-logs-rate-limit-us"
  }

  // Metrics CloudWatch Configuration - No need for Cloudwatch, but need to set these values
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "us-block-waf-acl"
    sampled_requests_enabled   = false
  }
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association
resource "aws_wafv2_web_acl_association" "rate_limit_us" {

  // General
  //
  // NOTE: The Amazon Resource Name (ARN) of the resource to associate with the web ACL, no need to 
  // have an ALB specific configuration
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.default.arn
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration
resource "aws_wafv2_web_acl_logging_configuration" "logs" {

  // General
  resource_arn = aws_wafv2_web_acl.default.arn

  // Log Config
  //
  // NOTE: An Amazon Kinesis Data Firehose resource must also be created with a PUT source (not a stream) and in the region 
  // that you are operating. Be sure to give the data firehose a name that starts with the prefix aws-waf-logs-.
  log_destination_configs = [
    aws_kinesis_firehose_delivery_stream.sink.arn
  ]
}
