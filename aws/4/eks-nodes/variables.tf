variable "name" {
  type        = string
  description = "Name of the cluster and roles"
}

variable "nodes_role_arn" {
  type        = string
  description = "EKS Node groups IAM Role"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version"
}

variable "subnets_node_group" {
  type        = list(string)
  description = "Private subnet(s)"
}

# Node Group
variable "ami_release_version" {
  type        = string
  description = "AMI release_version for the nodes"
}

variable "capacity_type" {
  type        = string
  description = "ON_DEMAND | SPOT"
  default     = "ON_DEMAND"
}

variable "disk_size" {
  type        = number
  description = "Disk size in GBs"
  default     = "20"
}

variable "instance_types" {
  type        = string
  description = "https://aws.amazon.com/ec2/instance-types/"
  default     = "t4g.medium"
}

variable "ami_type" {
  type        = string
  description = "AL2_x86_64 | AL2_x86_64_GPU | AL2_ARM_64 | CUSTOM | BOTTLEROCKET_ARM_64 | BOTTLEROCKET_x86_64 | BOTTLEROCKET_ARM_64_NVIDIA | BOTTLEROCKET_x86_64_NVIDIA | WINDOWS_CORE_2019_x86_64 | WINDOWS_FULL_2019_x86_64 | WINDOWS_CORE_2022_x86_64 | WINDOWS_FULL_2022_x86_64"
  default     = "AL2_ARM_64"
}

variable "ssh_key_name" {
  type        = string
  description = "Usually a RSA Pub Key to SSH the nodes in the Linux group"
}

#variable "nodes_ssh_sg_id" {
#  type = string
#  description = "Security Group ID to allow SSH from the Bastion to the Group Nodes"
#}
