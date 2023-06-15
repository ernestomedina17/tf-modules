output "nodes_role_arn" {
  value = aws_iam_role.nodes.arn
}

output "config_map_aws_auth_yaml" {
  value = <<CONFIGMAPAWSAUTH
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
CONFIGMAPAWSAUTH
}

output "manual_steps" {
  value = <<EOT
aws eks update-kubeconfig --region eu-central-1 --name ${var.name}
kubectl apply -f config_map_aws_auth.yaml
kubectl annotate serviceaccount -n kube-system aws-node eks.amazonaws.com/role-arn=${aws_iam_role.nodes.arn}
kubectl annotate serviceaccount -n kube-system aws-node eks.amazonaws.com/sts-regional-endpoints=true
EOT
}
