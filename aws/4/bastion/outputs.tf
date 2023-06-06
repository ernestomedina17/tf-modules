output "public_ip" {
  value = aws_instance.bastion.public_ip
}

output "arn" {
  value = aws_instance.bastion.arn
}

output "ssh_security_group" {
  value = aws_security_group.ssh.id
}

output "key_name" {
  value = aws_key_pair.ssh_pub_key.id
}
