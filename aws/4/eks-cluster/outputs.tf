output "cluster_id" {
  value = aws_eks_cluster.cluster.id
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

output "cert_authority_data" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "web_identity" {
  value = replace(aws_iam_openid_connect_provider.openid.url, "https://", "")
}

output "web_identity_arn" {
  value = aws_iam_openid_connect_provider.openid.arn
}

output "sg_id" {
  value = aws_eks_cluster.cluster.cluster_security_group_id
}
