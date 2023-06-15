locals {
  service_account_role_arn = "arn:aws:iam::${var.aws_account_id}:role/eks-node-group-${var.name}"
}
