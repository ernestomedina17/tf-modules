variable "aws_account_id" {
  type = string
}

variable "name" {
  type        = string
  description = "Name of the cluster and roles"
}

variable "iam_role_cluster_arn" {
  type        = string
  description = "IAM EKS Cluster Role"
}

variable "kube_proxy_version" {
  type        = string
  description = "v1.27.1-eksbuild.1"
}

#variable "coredns_version" {
#  type        = string
#  description = "v1.10.1-eksbuild.1"
#}

variable "vpc_cni_version" {
  type        = string
  description = "v1.12.6-eksbuild.2"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version"
}

variable "kms_key_arn" {
  type        = string
  description = "Encryption is required"
}

variable "subnets_cluster" {
  type        = list(string)
  description = "At least 2 subnets in different AZ are required"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Allow comm. between your worker nodes and the K8s control plane"
}

variable "endpoint_private_access" {
  type        = bool
  description = "only reachable from a private subnet"
}

variable "endpoint_public_access" {
  type        = bool
  description = "reachable from the internet"
}

variable "log_retention_days" {
  type = string
  description = "log retention policy in days"
}
