output "vpc_network_id" {
  value = aws_vpc.network.id
}

output "private_subnet_id" {
  value = [for az, subnet in aws_subnet.private : subnet.id]
}

output "public_subnet_id" {
  value = [for az, subnet in aws_subnet.public : subnet.id]
}

output "default_security_group_id" {
  value = aws_vpc.network.default_security_group_id
}
