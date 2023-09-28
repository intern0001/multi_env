terraform {
  source = "../../../../modules//argo/"  
}
include "root" {
  path = find_in_parent_folders()
}
dependency "eks" {
  config_path                             = "../eks/"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"] # Configure mock outputs for the "init", "validate", "plan" commands that are returned when there are no outputs available (e.g the module hasn't been applied yet.)
  mock_outputs = {
  cluster_name     = "fake-cluster_name"
  }
}
locals {
  # Load environment-wide variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  # Extract needed variables for reuse
 
  env        = local.environment_vars.locals.env
  
}
inputs = {
    argo_version     = "v2.8.0"
    cluster_name     = dependency.eks.outputs.cluster_name
    host             = "argocd-${local.env}.example.com"
    helm_repo        = "https://github.com/Khachik001/helm"
    argo_repo        = "https://github.com/Khachik001/argo.git"
    env              = local.env 
   
  }
 



dependencies {
    paths = ["../ingress/"]
}
  