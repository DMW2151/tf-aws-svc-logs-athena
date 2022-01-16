// Outputs

output "alb" {
  value       = aws_lb.alb.dns_name
  description = "..."
}
