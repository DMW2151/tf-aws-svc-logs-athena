// Define security groups for dummy service

// A very permissive group that allows all communication within the VPC
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "vpc_all_traffic_sg" {

  // General
  name                   = "vpc_all_traffic_sg"
  description            = "Allows ingress/egress on all ports from within the VPC"
  vpc_id                 = aws_vpc.core.id
  revoke_rules_on_delete = true

  // Ingress/Egress Rules
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.core.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.core.cidr_block]
  }

  // Tags
  tags = {
    Name = "tf-svc-logs-vpc-all-sg"
  }

}


// A group allowing all traffic into our ALB 
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "lb_sg" {

  // General
  name                   = "tf-svc-lb-sg"
  vpc_id                 = aws_vpc.core.id
  description            = "Allows incoming TCP traffic on 443 (HTTPS)"
  revoke_rules_on_delete = true

  // Ingress/Egress Rules 
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  // Ingress/Egress Rules 
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  // Expect LB is internet facing, send TCP traffic to anywhere
  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  // Tags 
  tags = {
    name = "tf-svc-logs-lb-sg"
  }

}
