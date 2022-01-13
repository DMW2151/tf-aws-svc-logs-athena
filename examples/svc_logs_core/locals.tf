locals {

  // Maps public subnet IDs -> private subnet IDs for dynamiclly configuring NAT, EIP, and Route Tables...
  paired_subnets = zipmap(
    [for s in aws_subnet.public : s.id], [for s in aws_subnet.private : s.id]
  )
}