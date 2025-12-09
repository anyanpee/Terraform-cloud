variable "aws_region" {
  description = "AWS region to build AMI"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Instance type for building AMI"
  type        = string
  default     = "t2.micro"
}
