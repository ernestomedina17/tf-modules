output "cluster_id" {
  value = aws_eks_cluster.cluster.id
}

output "node_group_id" {
  value = aws_eks_node_group.nodes.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "cluster_identity" {
  value = aws_eks_cluster.cluster.identity
}

output "eks_vpc_config" {
  value = aws_eks_cluster.cluster.vpc_config
}

output "cluster_role_arn" {
  value = aws_iam_role.cluster.arn
}

output "nodes_role_arn" {
  value = aws_iam_role.nodes.arn
}

output "cert_authority_data" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}
