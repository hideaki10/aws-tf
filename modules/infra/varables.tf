variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "num_subnets" {
  type        = number
  description = "The number of subnets to create"
}

variable "allowd_ips" {
  type        = set(string)
  description = "The allowed IPs"
}
