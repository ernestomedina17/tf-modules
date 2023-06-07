output "cluster_id" {
  value = aws_eks_cluster.cluster.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "cluster_identity" {
  value = aws_eks_cluster.cluster.identity
}

output "unicron_eks_vpc_config" {
  value = aws_eks_cluster.cluster.vpc_config
}

output "cluster_role_arn" {
  value = aws_iam_role.cluster.arn
}

output "nodes_role_arn" {
  value = aws_iam_role.nodes.arn
}


