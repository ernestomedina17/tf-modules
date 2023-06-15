resource "aws_eks_cluster" "cluster" {
  name     = var.name
  version  = var.k8s_version
  role_arn = var.iam_role_cluster_arn

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  # Private Cluster
  vpc_config {
    subnet_ids              = var.subnets_cluster
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = var.security_group_ids
  }

  # Different from your AWS VPC
  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
    ip_family         = "ipv4"
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "kube-proxy"
  addon_version            = var.kube_proxy_version
  service_account_role_arn = local.service_account_role_arn
  depends_on               = [aws_eks_cluster.cluster]
}

# If no nodes joined gives Status:Degraded InsufficientNumberOfReplicas
#resource "aws_eks_addon" "coredns" {
#  cluster_name                = aws_eks_cluster.cluster.name
#  addon_name                  = "coredns"
#  addon_version               = var.coredns_version
#  service_account_role_arn    = local.service_account_role_arn
#  depends_on               = [aws_eks_cluster.cluster]
#}

data "tls_certificate" "cert" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# Required by vpc-cni plugin
resource "aws_iam_openid_connect_provider" "openid" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.cert.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.cert.url
  depends_on      = [aws_eks_cluster.cluster]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "vpc-cni"
  addon_version            = var.vpc_cni_version
  service_account_role_arn = local.service_account_role_arn
  depends_on = [
    aws_iam_openid_connect_provider.openid,
    aws_eks_cluster.cluster
  ]
}
