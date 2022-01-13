// Define security groups for dummy service

// A very permissive group that allows any resource in the VPC to communicate with any other
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "vpc_all_traffic_sg" {

  // General
  name                   = "vpc_all_traffic_sg"
  description            = "Allows all access (ingress + egress) from within the VPC on all ports"
  vpc_id                 = aws_vpc.core.id
  revoke_rules_on_delete = true

  // Ingress/Egress Rules - Allow All Ports, All Protocols within the VPC
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

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "lb_sg" {

  // General
  name                   = "lb-sg"
  vpc_id                 = aws_vpc.core.id
  description            = "..."
  revoke_rules_on_delete = true

  // Ingress/Egress Rules 

  // Accept from anywhere on 443 - Listen Port for HTTPS
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  // Accept from anywhere on 80 - Listen Port for HTTP
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  // LB is internet facing; send TCP traffic to anywhere
  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  // Tags 
  tags = {
    name = "tf-svc-logs-lb-sg"
  }

}
