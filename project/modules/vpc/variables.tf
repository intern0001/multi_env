variable "vpc_cidr" {
  description = "The CIDR block for the main AWS VPC that will be created."
  type    = string
  default = "10.10.0.0/16"
}
variable "vpc_name" {
    type = string
    default = "intern_vpc"
}
variable "enable_nat_gateway" {
  default = true
  type = bool
  
}
variable "single_nat_gateway" {
  default = true
  type = bool
}
variable "one_nat_gateway_per_az" {
  default = false
  type = bool
}
variable "enable_dns_hostnames" {
  default = true
  type = bool
}
variable "enable_dns_support" {
  default = true
  type = bool
}
