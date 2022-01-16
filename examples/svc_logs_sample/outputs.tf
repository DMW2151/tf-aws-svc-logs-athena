// Outputs

output "test_endpoint" {
  value = aws_route53_record.alb.name
  description = "..."
}
