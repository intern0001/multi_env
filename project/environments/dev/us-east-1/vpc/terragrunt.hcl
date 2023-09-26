terraform {
  source = "../../../../modules//vpc/"  
}

include "root" {
  path = find_in_parent_folders()
}
locals {
  # Load environment-wide variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  # Extract needed variables for reuse
 
  env        = local.environment_vars.locals.env
  
  
}
inputs = {
  vpc_cidr="10.10.0.0/16"
  vpc_name="intern_vpc-${local.env}"
}
dependencies {
    paths = ["../ecr/"]
}
