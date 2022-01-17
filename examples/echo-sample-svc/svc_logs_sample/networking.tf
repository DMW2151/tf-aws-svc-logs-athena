// Configure the core networking for the dummy service - includes: 
//
//  - N x public subnets 
//  - N x private subnets 
//  - NAT + EIP + IGW s.t. private subnet instances can get downloads

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "public" {

  for_each = var.public_subnet_numbers

  // General - Subdivide into *.*.*.*/20 blocks...
  vpc_id                  = aws_vpc.core.id
  cidr_block              = cidrsubnet(aws_vpc.core.cidr_block, 4, each.value)
  availability_zone       = each.key
  map_public_ip_on_launch = true

  // Tags
  tags = {
    Name = "tf-svc-logs-public-${each.key}"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "private" {

  for_each = var.private_subnet_numbers

  // General - Subdivide into *.*.*.*/20 blocks...
  vpc_id                  = aws_vpc.core.id
  cidr_block              = cidrsubnet(aws_vpc.core.cidr_block, 4, each.value)
  availability_zone       = each.key
  map_public_ip_on_launch = false

  // Tags
  tags = {
    Name = "tf-svc-logs-private-${each.key}"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "core" {

  // General
  vpc_id = aws_vpc.core.id

  // Tags
  tags = {
    Name = "tf-svc-logs-igw"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "core" {

  for_each = aws_subnet.public

  // General
  vpc = true

  // To ensure proper ordering, it is recommended to add an explicit dependency
  // on the Internet Gateway for the VPC. Should be OK implicitly, but *could* 
  // cause a missing dep...
  depends_on = [
    aws_internet_gateway.core
  ]

  // Tags
  tags = {
    Name   = "tf-svc-logs-${each.value.availability_zone}"
    az     = each.value.availability_zone
    subnet = "${each.value.id}"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/nat_gateway
resource "aws_nat_gateway" "nat" {

  for_each = aws_eip.core

  // General 
  allocation_id = each.value.id
  subnet_id     = each.value.tags.subnet

  // To ensure proper ordering, it is recommended to add an explicit dependency
  // on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.core
  ]

  // Tags
  tags = {
    Name   = "tf-svc-logs-${each.value.tags.az}"
    subnet = each.value.tags.subnet
    az     = each.value.tags.az
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "public" {

  // General
  vpc_id = aws_vpc.core.id

  // Routes - Internet Traffic <> Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.core.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.core.id
  }

  // Tags
  tags = {
    Name = "tf-svc-logs-public-rt-tbl"
  }
}

// One Route Table for Each Private Subnet
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "private" {

  for_each = aws_nat_gateway.nat

  // General
  vpc_id = aws_vpc.core.id

  // Routes - Internet Traffic <> NAT Gateway, No IPV6 Traffic Through the NAT
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }


  // Tags
  tags = {
    Name           = "tf-svc-logs-private-rt-tbl-${each.value.tags.az}"
    public_subnet  = each.value.tags.subnet
    private_subnet = lookup(local.paired_subnets, each.value.tags.subnet, "-")
  }
}

// NOTE: Probably could use the default main route table
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "public" {

  for_each = aws_subnet.public

  // General 
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

// Associate private route tables to each of their respective subnets; e.g. use1-az4 private goes through 
// NAT in use1-az4
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "private" {

  for_each = aws_route_table.private

  // General
  subnet_id      = each.value.tags.private_subnet
  route_table_id = each.value.id
}
