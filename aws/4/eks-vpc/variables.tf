variable "name" {
  type        = string
  description = "A name for this stack."
}

variable "region" {
  type        = string
  description = "Region where this stack will be deployed."
}

variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC."
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to create subnets in"
}

variable "az_counts" {
  type    = number
  description = "Number of Availability Zones in the region"
  default = 3
}
