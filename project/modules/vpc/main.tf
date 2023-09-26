terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}

# Data source to retrieve AWS availability zones
data "aws_availability_zones" "azs" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"
  
  # Name and CIDR block for the VPC 

  name = var.vpc_name
  cidr = var.vpc_cidr
  
  # Define the availability zones, subnets, and NAT gateway configuration
   
  azs             = data.aws_availability_zones.azs.names
  private_subnets = slice(cidrsubnets(var.vpc_cidr, 8, 8, 8, 8), 0, 2)
  public_subnets  = slice(cidrsubnets(var.vpc_cidr, 8, 8, 8, 8), 2, 4)

 # Single NAT Gateway
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
###################################
   # DNS Configuration
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support = var.enable_dns_support

}