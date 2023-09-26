terraform {
  source = "../../../../modules//eks/"  
}
include "root" {
  path = find_in_parent_folders()
}
dependency "vpc" {
  config_path                             = "../vpc/"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"] # Configure mock outputs for the "init", "validate", "plan" commands that are returned when there are no outputs available (e.g the module hasn't been applied yet.)
  mock_outputs = {
  vpc_id = "vpc-fake-id"
  private_subnets = "fake-subnets"
  }
}
locals {
  # Load environment-wide variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  # Extract needed variables for reuse
 
  env        = local.environment_vars.locals.env
  
  
}

inputs = {
   cluster_name = "intern_eks-${local.env}"
   vpc_id = dependency.vpc.outputs.vpc_id
   private_subnets = dependency.vpc.outputs.private_subnets
  }
 



dependencies {
    paths = ["../vpc/"]
}
  