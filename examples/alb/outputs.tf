output "alb_table" {
  value       = module.svc_logs.alb_table.name
  description = "The Catalog table..."
}