// Launch worker instances for our dummy infrastructure 

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "workers" {

  // Basic 
  ami           = var.instance_ami
  instance_type = var.instance_size

  // Launch one (1) instance in each private subnet
  for_each = aws_subnet.private

  // Security + Networking 
  //
  // worker instances allow access from within the VPC; internet access configured through
  // a NAT -> IGW gateway elsewhere...
  availability_zone = each.value.availability_zone
  subnet_id         = each.value.id
  vpc_security_group_ids = [
    aws_security_group.vpc_all_traffic_sg.id,
  ]

  // Storage - Use default storage; smallest allowable EBS size &&
  // ensure DO NOT keep on termination
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true

    tags = {
      Name = "Worker Instance - ${each.value.availability_zone}"
    }

  }

  // Monitoring + Metadata - These *should* be default, enable explicitly 
  monitoring = true
  metadata_options {
    http_endpoint = "enabled"
  }

  // User Data - start-up a `echo` container; see script for details
  user_data = file("${path.module}/user_data/start_svc.sh")

  // Tags
  tags = {
    Name = "tf-svc-logs-worker-instance-${each.value.availability_zone}"
  }
}