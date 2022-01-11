// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query
resource "aws_athena_named_query" "foo" {
  name      = "Sample Query (1)"
  description = "Foo..."
  database  = var.src_athena_db_name
  query     = "SELECT * FROM ${var.src_athena_db_name}.${var.src_athena_table_name} limit 10;"
}


// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query
resource "aws_athena_named_query" "bar" {
  name      = "Sample Query (2)"
  description = "Foo..."
  database  = var.src_athena_db_name
  query     = "SELECT * FROM ${var.src_athena_db_name}.${var.src_athena_table_name} limit 10;"
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query
resource "aws_athena_named_query" "baz" {
  name      = "Sample Query (3)"
  description = "Foo..."
  database  = var.src_athena_db_name
  query     = "SELECT * FROM ${var.src_athena_db_name}.${var.src_athena_table_name} WHERE elb_status_code >= 500 ORDER BY TIME desc;"
}