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
      variable = "${var.web_identity}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.web_identity}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [var.web_identity_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "nodes" {
  name               = "eks-node-group-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.nodes.json
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

# The following manual steps are required by EKS to use the role.
resource "local_file" "aws_auth_configmap" {
    filename = local.configmap_filepath
    content  = <<EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.nodes.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOT
}

resource "null_resource" "eks_configs_and_annotations" {
  provisioner "local-exec" {
    command     = "[ -e  ${local.configmap_filepath} ] && rm -v ~/.kube/config || echo 0"
    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --region eu-central-1 --name ${var.name}"
    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    command     = "kubectl apply -f ${local.configmap_filepath}"
    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    command     = "kubectl annotate serviceaccount -n kube-system aws-node eks.amazonaws.com/role-arn=${aws_iam_role.nodes.arn}"
    interpreter = ["/bin/bash", "-c"]
  }

  # Check in IAM - Account Settings - STS - if your region is enabled.
  provisioner "local-exec" {
    command     = "kubectl annotate serviceaccount -n kube-system aws-node eks.amazonaws.com/sts-regional-endpoints=true"
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    local_file.aws_auth_configmap,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy
  ]
}
