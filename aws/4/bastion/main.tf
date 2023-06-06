resource "aws_instance" "bastion" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  security_groups = concat(var.security_groups, [aws_security_group.ssh.id])
  key_name        = aws_key_pair.ssh_pub_key.id

  tags = { Name = var.name }

  lifecycle {
    ignore_changes = [
      tags,
      capacity_reservation_specification,
      cpu_options,
      credit_specification,
      enclave_options,
      maintenance_options,
      metadata_options,
      private_dns_name_options,
      root_block_device,
    ]
  }
}

resource "aws_key_pair" "ssh_pub_key" {
  key_name   = var.name
  public_key = sensitive(var.ssh_pub_key_content)
}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH from Internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "allow_ssh" }
}
