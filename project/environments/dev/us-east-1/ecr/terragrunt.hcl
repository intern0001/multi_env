terraform {
  source = "../../../../modules//ecr/"  
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
    ecr_repo_name = "private-ecr-${local.env}"
    
  }
 

  