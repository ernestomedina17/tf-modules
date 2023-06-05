resource "aws_vpc" "network" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags                 = { Name = var.name }
  lifecycle { ignore_changes = [tags, ] }
}

resource "aws_subnet" "public" {
  count = var.az_counts

  availability_zone       = var.availability_zones[count.index]
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index)
  vpc_id                  = aws_vpc.network.id
  map_public_ip_on_launch = true

  tags = {
    Name                             = "${var.name}-public-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb"         = "1"
    "kubernetes.io/role/alb-ingress" = "1"
    "subnet-type"                    = "public"
  }

  lifecycle { ignore_changes = [tags] }
}

# The default route, mapping the VPC's CIDR block to "local", is created implicitly.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.network.id
  tags   = { Name = "${var.name}-public" }
}

resource "aws_route_table_association" "public" {
  count          = var.az_counts
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.network.id
  tags   = { Name = var.name }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
  depends_on             = [aws_internet_gateway.public]
}

resource "aws_subnet" "private" {
  count = var.az_counts

  availability_zone       = var.availability_zones[count.index]
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index + 4)
  vpc_id                  = aws_vpc.network.id
  map_public_ip_on_launch = false

  tags = {
    Name                              = "${var.name}-private-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/role/alb-ingress"  = "1"
    "subnet-type"                     = "private"
  }

  lifecycle { ignore_changes = [tags] }
}

resource "aws_default_route_table" "private" {
  default_route_table_id = aws_vpc.network.default_route_table_id
  tags                   = { Name = "${var.name}-private" }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private.id
  depends_on             = [aws_internet_gateway.public]
}

resource "aws_route_table_association" "private" {
  count          = var.az_counts
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_default_route_table.private.id
}

# Only one as of now to save money.
resource "aws_nat_gateway" "private" {
  #count             = var.az_counts
  connectivity_type = "private"
  #subnet_id         = aws_subnet.private.*.id[count.index]
  subnet_id = aws_subnet.private.*.id[0]
}
