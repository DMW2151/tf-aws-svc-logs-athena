
// Note: 
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table
resource "aws_glue_catalog_table" "vpc_logs_src" {

  // General  
  name          = var.vpc_logs_tbl_name
  database_name = var.athena_db_name
  table_type    = "EXTERNAL_TABLE"
  description   = "VPC Flow logs From ${local.vpc_src_s3_path}"

  parameters = {
    // General
    EXTERNAL                      = "TRUE"
    "projection.enabled"          = tostring(var.enable_projected_partitions)
    "has_encrypted_data"          = "false"
    "partition_filtering.enabled" = tostring(var.enable_partition_filtering)

    // Partition Projection - Region - All Active Regions
    "projection.region.type"   = "enum"
    "projection.region.values" = join(", ", var.organization_enabled_regions)

    // Partition Projection - Accounts in Org
    "projection.account_id.type"   = "enum"
    "projection.account_id.values" = join(", ", var.organization_account_ids != "" ? var.organization_account_ids : [data.aws_caller_identity.current.id])
  }

  // Partition Indexes
  partition_index {
    index_name = "date_partition_index"
    keys       = ["date"]
  }

  // Partition Columns
  partition_keys {
    name    = "date"
    type    = "string"
    comment = "The type of request or connection."
  }

  storage_descriptor {

    location      = local.vpc_src_s3_path // TODO: CHECK
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    // VPC - Table Schema 
    // Comments From: https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html
    columns {
      name    = "version"
      type    = "int"
      comment = "The VPC Flow Logs version. If you use the default format, the version is 2. If you use a custom format, the version is the highest version among the specified fields. "
    }

    columns {
      name    = "account_id"
      type    = "string"
      comment = "The ID of the network interface for which the traffic is recorded"
    }

    columns {
      name    = "interface_id"
      type    = "string"
      comment = "The ID of the network interface for which the traffic is recorded."
    }

    columns {
      name    = "srcaddr"
      type    = "string"
      comment = "The source address for incoming traffic, or the IPv4 or IPv6 address of the network interface for outgoing traffic on the network interface. The IPv4 address of the network interface is always its private IPv4 address."
    }

    columns {
      name    = "dstaddr"
      type    = "string"
      comment = "The destination address for outgoing traffic, or the IPv4 or IPv6 address of the network interface for incoming traffic on the network interface. The IPv4 address of the network interface is always its private IPv4 address."
    }

    columns {
      name    = "srcport"
      type    = "int"
      comment = "The source port of the traffic."
    }

    columns {
      name    = "dstport"
      type    = "int"
      comment = "The destination port of the traffic."
    }

    columns {
      name    = "protocol"
      type    = "int"
      comment = "The IANA protocol number of the traffic. For more information, see Assigned Internet Protocol Numbers"
    }

    columns {
      name    = "packets"
      type    = "string"
      comment = "The number of packets transferred during the flow."
    }

    columns {
      name    = "bytes"
      type    = "string"
      comment = "The number of bytes transferred during the flow."
    }

    columns {
      name    = "start"
      type    = "string"
      comment = "The time, in Unix seconds, when the first packet of the flow was received within the aggregation interval. This might be up to 60 seconds after the packet was transmitted or received on the network interface."
    }

    columns {
      name    = "end"
      type    = "string"
      comment = "The time, in Unix seconds, when the last packet of the flow was received within the aggregation interval. This might be up to 60 seconds after the packet was transmitted or received on the network interface."
    }

    columns {
      name    = "action"
      type    = "string"
      comment = "The action that is associated with the traffic. ACCEPT | REJECT — The recorded traffic was permitted/not permitted by the security groups and network ACLs."
    }

    columns {
      name    = "log_status"
      type    = "string"
      comment = "The logging status of the flow log. OK | NODATA | SKIPDATA"
    }

    columns {
      name    = "vpc_id"
      type    = "string"
      comment = "The ID of the VPC that contains the network interface for which the traffic is recorded."
    }

    columns {
      name    = "subnet_id"
      type    = "string"
      comment = "The ID of the subnet that contains the network interface for which the traffic is recorded."
    }

    columns {
      name    = "instance_id"
      type    = "string"
      comment = "The ID of the instance that's associated with network interface for which the traffic is recorded, if the instance is owned by you."
    }

    columns {
      name    = "tcp_flags"
      type    = "string"
      comment = "The bitmask value for the following TCP flags, SYN | SYN-ACK | FIN | RST. See TCP Flag Sequence"
    }

    columns {
      name    = "type"
      type    = "string"
      comment = "The type of traffic. The possible values are: IPv4 | IPv6 | EFA. For more information, see Elastic Fabric Adapter."
    }

    columns {
      name    = "pkt_srcaddr"
      type    = "string"
      comment = "The packet-level (original) source IP address of the traffic. Use this field with the srcaddr field to distinguish between the IP address of an intermediate layer through which traffic flows, and the original source IP address of the traffic."
    }

    columns {
      name    = "pkt_dstaddr"
      type    = "string"
      comment = "The packet-level (original) destination IP address for the traffic. Use this field with the dstaddr field to distinguish between the IP address of an intermediate layer through which traffic flows, and the final destination IP address of the traffic."
    }

    columns {
      name    = "region"
      type    = "string"
      comment = "The Region that contains the network interface for which traffic is recorded."
    }

    columns {
      name    = "az_id"
      type    = "string"
      comment = "The ID of the Availability Zone that contains the network interface for which traffic is recorded. If the traffic is from a sublocation, the record displays a '-' symbol for this field."
    }

    columns {
      name    = "sublocation_type"
      type    = "string"
      comment = "The type of sublocation that's returned in the sublocation-id field. The possible values are: wavelength | outpost | localzone. If the traffic is not from a sublocation, the record displays a '-' symbol for this field."
    }

    columns {
      name    = "sublocation_id"
      type    = "string"
      comment = "The ID of the sublocation that contains the network interface for which traffic is recorded. If the traffic is not from a sublocation, the record displays a '-' symbol for this field."
    }

    columns {
      name    = "pkt_src_aws_service"
      type    = "string"
      comment = "The name of the subset of IP address ranges for the pkt-srcaddr field, if the source IP address is for an AWS service. "
    }

    columns {
      name    = "pkt_dst_aws_service"
      type    = "string"
      comment = "The name of the subset of IP address ranges for the pkt-dstaddr field, if the destination IP address is for an AWS service. For a list of possible values, see the pkt-src-aws-service field."
    }

    columns {
      name    = "flow_direction"
      type    = "string"
      comment = "The direction of the flow with respect to the interface where traffic is captured. The possible values are: ingress | egress."
    }

    columns {
      name    = "traffic_path"
      type    = "string"
      comment = "The path that egress traffic takes to the destination. To determine whether the traffic is egress traffic, check the flow-direction field. See AWS Reference"
    }


  }

}
