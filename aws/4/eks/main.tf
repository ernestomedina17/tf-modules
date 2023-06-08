resource "aws_eks_cluster" "cluster" {
  name     = var.name
  version  = var.k8s_version
  role_arn = aws_iam_role.cluster.arn

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  # Using previate subnets whenever possible is recommended.
  vpc_config {
    subnet_ids = var.subnets_cluster
  }

  # Different from your AWS VPC
  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
    ip_family         = "ipv4"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cluster" {
  name               = "eks-cluster-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

resource "local_file" "aws_auth_configmap" {
  content         = local.config_map_aws_auth
  filename        = local.config_map_aws_auth_file_path
  file_permission = "0644"
}

resource "null_resource" "kubectl" {
  provisioner "local-exec" {
    command     = "[ -e ${local.config_map_aws_auth_file_path} ] && rm -v ~/.kube/config || echo 0"
    interpreter = ["/bin/bash", "-c"]
  }
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --region eu-central-1 --name ${var.name}"
    interpreter = ["/bin/bash", "-c"]
  }
  provisioner "local-exec" {
    command     = "kubectl apply -f ${local.config_map_aws_auth_file_path}"
    interpreter = ["/bin/bash", "-c"]
  }

  #provisioner "local-exec" {
  #  command     = 'eksctl get cluster --name ${var.name} -o json | jq --raw-output '.[] | "[settings.kubernetes]\napi-server = \"" + .Endpoint + "\"\ncluster-certificate =\"" + .CertificateAuthority.Data + "\"\ncluster-name = \"unicron\""''
  #  interpreter = ["/bin/bash", "-c"]
  #}

  depends_on = [
    local_file.aws_auth_configmap,
    aws_eks_cluster.cluster
  ]
}

# AWS says this is not required but the nodes won't work without it.
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "vpc-cni"
  depends_on   = [aws_eks_cluster.cluster]
}

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

data "aws_iam_policy_document" "nodes" {

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.openid.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.openid.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.openid.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "nodes" {
  name               = "eks-node-group-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.nodes.json
  depends_on         = [aws_eks_cluster.cluster]
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# Bottlerocket's default SSM agent to get a shell session on the instance.
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.nodes.name
}

resource "null_resource" "annotate_serviceaccount" {
  provisioner "local-exec" {
    command     = "kubectl annotate serviceaccount -n kube-system aws-node eks.amazonaws.com/role-arn=${aws_iam_role.nodes.arn}"
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonSSMManagedInstanceCore,
  ]
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.name
  node_role_arn   = aws_iam_role.nodes.arn
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

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonSSMManagedInstanceCore,
    null_resource.annotate_serviceaccount,
  ]
}
