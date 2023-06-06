variable "ami_id" {
  type        = string
  description = "AMI ID of for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "https://aws.amazon.com/ec2/instance-types/"
}

variable "subnet_id" {
  type        = string
  description = "Public subnet to deploy the instance"
}

variable "security_groups" {
  type        = list(string)
  description = "Pass the default vpc SG plus others if needed, NO need for SSH"
}

variable "name" {
  type        = string
  description = "Name of the instance"
}

variable "ssh_key_name" {
  type        = string
  description = "name or id of the aws_key_pair"
}

variable "ssh_pub_key_content" {
  type        = string
  sensitive   = true
  description = "ssh rsa pub key"
}

variable "vpc_id" {
  type        = string
  description = "VPC id containing the subnet"
}
