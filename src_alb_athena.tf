
// Application Load Balancer Table 
//
// AWS ALB Docs: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
//


// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table
resource "aws_glue_catalog_table" "alb_logs_src" {

  // General
  name          = var.alb_logs_tbl_name
  database_name = var.athena_db_name
  table_type    = "EXTERNAL_TABLE"
  description   = "Application Load Balancer (ALB) logs From ${local.alb_src_s3_path}"

  // Table Properties
  parameters = {

    // General
    EXTERNAL                      = "TRUE"
    "has_encrypted_data"          = "false"
    "projection.enabled"          = tostring(var.enable_projected_partitions)
    "partition_filtering.enabled" = tostring(var.enable_partition_filtering)

    // Partition Projection - Date
    "projection.date.type"   = "date"
    "projection.date.range"  = "2022/01/01,NOW"
    "projection.date.format" = "yyyy/MM/dd"

    // Partition Projection - Region - All Active Regions
    "projection.region.type"   = "enum"
    "projection.region.values" = join(", ", var.organization_enabled_regions)

    // Partition Projection - Accounts in Org
    "projection.account_id.type"   = "enum"
    "projection.account_id.values" = join(", ", var.organization_account_ids != "" ? var.organization_account_ids : [data.aws_caller_identity.current.id])

    // Storage Location
    "storage.location.template" = "${local.alb_src_s3_path}AWSLogs/$${account_id}/elasticloadbalancing/$${region}/$${date}/"

  }

  // Partition Indexes
  partition_index {
    index_name = "date_partition_index"
    keys       = ["date"]
  }

  // Partition Columns
  partition_keys {
    name    = "account_id"
    type    = "string"
    comment = "The ID of the network interface for which the traffic is recorded"
  }

  partition_keys {
    name    = "region"
    type    = "string"
    comment = "The Region that contains the network interface for which traffic is recorded."
  }

  partition_keys {
    name    = "date"
    type    = "string"
    comment = "The type of request or connection."
  }

  storage_descriptor {

    location      = local.alb_src_s3_path // TODO: CHECK
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "alb-default-serde"
      serialization_library = "org.apache.hadoop.hive.serde2.RegexSerDe"

      parameters = {
        "serialization.format" = 1
        "input.regex"          = "([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*):([0-9]*) ([^ ]*)[:-]([0-9]*) ([-.0-9]*) ([-.0-9]*) ([-.0-9]*) (|[-0-9]*) (-|[-0-9]*) ([-0-9]*) ([-0-9]*) \"([^ ]*) (.*) (- |[^ ]*)\" \"([^\"]*)\" ([A-Z0-9-_]+) ([A-Za-z0-9.-]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([-.0-9]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^ ]*)\" \"([^s]+?)\" \"([^s]+)\" \"([^ ]*)\" \"([^ ]*)\""
      }
    }

    // ALB - Table Schema 
    // Comments From: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-log-entry-syntax
    columns {
      name    = "type"
      type    = "string"
      comment = "The type of request or connection."
    }

    columns {
      name    = "time"
      type    = "string"
      comment = "The time when the load balancer generated a response to the client, in ISO 8601 format. For WebSockets, this is the time when the connection is closed."
    }

    columns {
      name    = "elb"
      type    = "string"
      comment = "The resource ID of the load balancer. If you are parsing access log entries, note that resources IDs can contain forward slashes (/)."
    }

    columns {
      name    = "client_ip"
      type    = "string"
      comment = "The IP address of the requesting client."
    }

    columns {
      name    = "client_port"
      type    = "int"
      comment = "The port of the requesting client."
    }

    columns {
      name    = "target_ip"
      type    = "string"
      comment = "The IP address and port of the requesting client."
    }

    columns {
      name    = "target_port"
      type    = "int"
      comment = "The IP address and port of the target that processed this request."
    }

    columns {
      name    = "request_processing_time"
      type    = "double"
      comment = "The total time elapsed (in seconds, with ms precision) from the time the load balancer received the request until the time it sent the request to a target. "
    }

    columns {
      name    = "target_processing_time"
      type    = "double"
      comment = "The total time elapsed (in seconds, with ms precision) from the time the load balancer sent the request to a target until the target started to send the response headers."
    }

    columns {
      name    = "response_processing_time"
      type    = "double"
      comment = "The total time elapsed (in seconds, with ms precision) from the time the load balancer received the response header from the target until it started to send the response to the client."
    }

    columns {
      name    = "elb_status_code"
      type    = "int"
      comment = "The status code of the response from the load balancer. "
    }

    columns {
      name    = "target_status_code"
      type    = "string"
      comment = "The status code of the response from the target. This value is recorded only if a connection was established to the target and the target sent a response. Otherwise, it is set to -."
    }

    columns {
      name    = "received_bytes"
      type    = "bigint"
      comment = "The size of the request, in bytes, received from the client (requester). For HTTP requests, this includes the headers. For WebSockets, this is the total number of bytes received from the client on the connection."
    }

    columns {
      name    = "sent_bytes"
      type    = "bigint"
      comment = "The size of the response, in bytes, sent to the client (requester). For HTTP requests, this includes the headers. For WebSockets, this is the total number of bytes sent to the client on the connection. "
    }

    columns {
      name    = "request_verb"
      type    = "string"
      comment = "..."
    }

    columns {
      name    = "request_url"
      type    = "string"
      comment = "The request line from the client, enclosed in double quotes and logged using the following format: HTTP method + protocol://host:port/uri + HTTP version"
    }

    columns {
      name    = "request_proto"
      type    = "string"
      comment = "..."
    }

    columns {
      name    = "user_agent"
      type    = "string"
      comment = "A User-Agent string that identifies the client that originated the request, enclosed in double quotes. The string consists of one or more product identifiers, product[/version]."
    }

    columns {
      name    = "ssl_cipher"
      type    = "string"
      comment = "[HTTPS listener] The SSL cipher. This value is set to - if the listener is not an HTTPS listener. "
    }

    columns {
      name    = "ssl_protocol"
      type    = "string"
      comment = "[HTTPS listener] The SSL protocol. This value is set to - if the listener is not an HTTPS listener. "
    }

    columns {
      name    = "target_group_arn"
      type    = "string"
      comment = "The Amazon Resource Name (ARN) of the target group."
    }

    columns {
      name    = "trace_id"
      type    = "string"
      comment = "The contents of the X-Amzn-Trace-Id header, enclosed in double quotes. "
    }

    columns {
      name    = "domain_name"
      type    = "string"
      comment = "[HTTPS listener] The SNI domain provided by the client during the TLS handshake, enclosed in double quotes."
    }

    columns {
      name    = "chosen_cert_arn"
      type    = "string"
      comment = "[HTTPS listener] The ARN of the certificate presented to the client, enclosed in double quotes. This value is set to session-reused if the session is reused. This value is set to - if the listener is not an HTTPS listener."
    }

    columns {
      name    = "matched_rule_priority"
      type    = "string"
      comment = "The priority value of the rule that matched the request. If a rule matched, this is a value from 1 to 50,000. If no rule matched and the default action was taken, this value is set to 0."
    }

    columns {
      name    = "request_creation_time"
      type    = "string"
      comment = "The time when the load balancer received the request from the client, in ISO 8601 format. "
    }

    columns {
      name    = "actions_executed"
      type    = "string"
      comment = "The actions taken when processing the request, enclosed in double quotes. "
    }

    columns {
      name    = "redirect_url"
      type    = "string"
      comment = "The URL of the redirect target for the location header of the HTTP response, enclosed in double quotes. If no redirect actions were taken, this value is set to -."
    }

    columns {
      name    = "lambda_error_reason"
      type    = "string"
      comment = "The error reason code, enclosed in double quotes. If the request failed, this is one of the error codes described in Error reason codes."
    }

    columns {
      name    = "target_port_list"
      type    = "string"
      comment = "A space-delimited list of IP addresses and ports for the targets that processed this request, enclosed in double quotes. Currently, this list can contain one item and it matches the target:port field. "
    }

    columns {
      name    = "target_status_code_list"
      type    = "string"
      comment = "A space-delimited list of status codes from the responses of the targets, enclosed in double quotes. Currently, this list can contain one item and it matches the target_status_code field."
    }

    columns {
      name    = "classification"
      type    = "string"
      comment = "The classification for desync mitigation, enclosed in double quotes. If the request does not comply with RFC 7230, the possible values are Acceptable, Ambiguous, and Severe."
    }

    columns {
      name    = "classification_reason"
      type    = "string"
      comment = "The classification reason code, enclosed in double quotes. If the request does not comply with RFC 7230, this is one of the classification codes described in Classification reasons."
    }

  }

}
