output "public_ip" {
  value = aws_instance.bastion.public_ip
}

output "arn" {
  value = aws_instance.bastion.arn
}

output "ssh_security_group" {
  value = aws_security_group.ssh.id
}
