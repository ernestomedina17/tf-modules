resource "aws_security_group" "eks_cluster" {
  name        = "eks-cluster-${var.name}"
  description = "https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html"
  vpc_id      = var.vpc_id

  # Needs to be added manually: aws:eks:cluster-name as AWS rejects the double colons. 
  tags = {
    Name                                = "eks-cluster-sg-${var.name}-15062023"
    "kubernetes.io/cluster/${var.name}" = "owned"
    "aws:eks:cluster-name"              = var.name
    #"aws\u003Aeks\u003Acluster-name"    = var.name
  }
}

# TO-DO: Enhance Security 
resource "aws_security_group_rule" "ingress_default" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks_cluster.id
}

resource "aws_security_group_rule" "egress_default" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.eks_cluster.id
}
