# EKS VPC Terraform Module

Creates:
- aws_vpc.
- One public aws_subnet per AZ.
- One private aws_subnet per AZ. 
- aws_internet_gateway (aiw)
- aws_route_table & its association to the public subnets and aiw
- aws_route_table & its private aws_route_table_association
- aws_nat_gateway for the private subnets
