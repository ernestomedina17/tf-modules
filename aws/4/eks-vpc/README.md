# EKS VPC Terraform Module

If you pass "10.0.0.0/16" as CIDR in a region of 3 Availability Zones, the following network will be created: 

- VPC CIDR: "10.0.0.0/16"
- 3 Public Subnets: 
 - 10.0.0.0/20 
 - 10.0.16.0/20
 - 10.0.32.0/20
- 3 Private Subnets: 
 - 10.0.64.0/20
 - 10.0.80.0/20
 - 10.0.96.0/20

Warning: Not tested with different CIDRs, nor other than 3 AZs.

## Notes
Instances in the private subnet cannot have public IPs, 
rather traffic gets NATed to the public subnets.

