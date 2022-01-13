variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "10.0.0.0/16"
}

// aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/recommended
variable "instance_ami" {
  type        = string
  default     = "ami-0c5c9bcfb36b772fe"
  description = "The AMI..."
}

variable "logging_bucket" {

  type = string

  description = "S3 location to sink all logs to"
  default     = "dmw2151-service-logs"
}

variable "instance_size" {
  type        = string
  default     = "t3.micro"
  description = "The AMI..."
}

variable "public_subnet_numbers" {

  type        = map(number)
  description = "Map of AZ to a number that should be used for public subnets"

  default = {
    "us-east-1a" = 1
    "us-east-1b" = 2
  }

}

variable "private_subnet_numbers" {

  type        = map(number)
  description = "Map of AZ to a number that should be used for private subnets"

  default = {
    "us-east-1a" = 3
    "us-east-1b" = 4
  }
}