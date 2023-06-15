variable "name" {
  type        = string
  description = "Name of the cluster and roles"
}

variable "web_identity" {
  type        = string
  description = "openid endpoint"
}

variable "web_identity_arn" {
  type        = string
  description = "openid arn"
}
