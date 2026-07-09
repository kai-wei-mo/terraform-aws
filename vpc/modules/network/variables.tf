variable "name" {
  description = "Name prefix for VPC resources (tags)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR (NAT gateway)"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
}

variable "availability_zone" {
  description = "AZ for both subnets"
  type        = string
}
