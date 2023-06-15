resource "aws_eks_node_group" "nodes" {
  cluster_name    = var.name
  node_group_name = var.name
  node_role_arn   = var.nodes_role_arn
  subnet_ids      = var.subnets_node_group
  version         = var.k8s_version
  release_version = var.ami_release_version
  capacity_type   = var.capacity_type    # default
  disk_size       = var.disk_size        # default
  instance_types  = [var.instance_types] # default
  ami_type        = var.ami_type         # default

  remote_access {
    ec2_ssh_key = var.ssh_key_name
    #source_security_group_ids = var.nodes_ssh_sg
  }

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  update_config {
    max_unavailable = 1
  }
}
