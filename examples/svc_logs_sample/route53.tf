
// NOTE: This assumes a pre-configured hosted zone in AWS that can be used as a test environment
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "build" {
  name         = var.build_domain
  private_zone = false
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record 
resource "aws_route53_record" "alb" {

  // General
  zone_id = data.aws_route53_zone.build.zone_id
  name    = "alb-${random_pet.random.id}.${var.build_domain}"
  type    = "CNAME"
  ttl     = "300"

  // Records
  records = [
    aws_lb.alb.dns_name
  ]
}
