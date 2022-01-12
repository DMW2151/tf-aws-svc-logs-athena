// Outputs all from aws_glue_catalog_table
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table

output "alb_table" {
  value       = aws_glue_catalog_table.alb_logs_src
  description = "The Catalog table..."
}

