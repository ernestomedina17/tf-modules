resource "aws_vpc" "eks_network" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags                 = { Name = var.name }
  lifecycle { ignore_changes = [tags, ] }
}

resource "aws_internet_gateway" "eks_network_internet_gateway" {
  vpc_id = aws_vpc.eks_network.id
  tags   = { Name = var.name }
}

resource "aws_route_table" "eks_network_public" {
  vpc_id = aws_vpc.eks_network.id
  tags   = { Name = "${var.name}-public" }
}

resource "aws_route" "internet-gateway" {
  route_table_id         = aws_route_table.eks_network_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_network_internet_gateway.id
}

resource "aws_default_route_table" "eks_network_private" {
  default_route_table_id = aws_vpc.eks_network.default_route_table_id
  tags                   = { Name = "${var.name}-private" }
}

resource "aws_subnet" "public" {
  count = var.az_counts

  availability_zone       = var.availability_zones[count.index]
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index)
  vpc_id                  = aws_vpc.eks_network.id
  map_public_ip_on_launch = true

  tags = {
    Name                             = "${var.name}-public-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb"         = "1"
    "kubernetes.io/role/alb-ingress" = "1"
    "subnet-type"                    = "public"
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "aws_route_table_association" "public" {
  count = var.az_counts

  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.eks_network_public.id
}

resource "aws_subnet" "private" {
  count = var.az_counts

  availability_zone       = var.availability_zones[count.index]
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index + 4)
  vpc_id                  = aws_vpc.eks_network.id
  map_public_ip_on_launch = false

  tags = {
    Name                              = "${var.name}-private-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/role/alb-ingress"  = "1"
    "subnet-type"                     = "private"
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
