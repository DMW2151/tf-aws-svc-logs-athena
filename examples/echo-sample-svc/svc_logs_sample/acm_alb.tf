// Uses the hashicorp/tls module to create a self-signed cert for the test domain
// and then uploads the result as an AWS certificate

// Resource: https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request
resource "tls_private_key" "alb" {
  algorithm = "RSA"
}

// Resource: https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert
resource "tls_self_signed_cert" "alb" {

  // General
  key_algorithm         = tls_private_key.alb.algorithm
  private_key_pem       = tls_private_key.alb.private_key_pem
  validity_period_hours = 3 // Certificate expires after 3 hours. self-signed, shouldn't matter either way...

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  // TODO: This should be a bit more restrictive; even for a test domain
  dns_names = [
    "*.${var.build_domain}"
  ]

  // ACME options
  subject {
    common_name  = var.build_domain
    organization = "ACME"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate 
resource "aws_acm_certificate" "alb" {
  certificate_body = tls_self_signed_cert.alb.cert_pem
  private_key      = tls_private_key.alb.private_key_pem
}
