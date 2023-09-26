variable "env" {
  type = string
  default = ""

}
# Argocd version
variable "argo_version" {
  type    = string
  default = "v2.8.0"
}
# Image updater version
variable "updater_version" {
  type    = string
  default = "v0.12.2"

}
variable "cluster_name" {
  default = ""
}
# host for argocd
variable "host" {
  default = "argocd.example.com"
}
# AWS account id
variable "account_id" {
  default = ""

}
variable "aws_region" {
  default = ""

}
# Argo cd repo which will used to deploy application 
variable "argo_repo" {
  default = ""

}

variable "github_token" {

  type      = string
  default   = ""
  sensitive = true
}

variable "github_name" {
  type      = string
  default   = ""
  sensitive = true
}
variable "helm_repo" {
  type    = string
  default = ""


}


locals {
  #get value from data if the variable has not received a value
  github_name  = var.github_name == "" ? "${data.aws_ssm_parameter.github_name.value}" : "${var.github_name}" 
  github_token = var.github_token == "" ? "${data.aws_ssm_parameter.github_token.value}" : "${var.github_token}"
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  aws_region   = data.aws_region.current.name
  account_id   = data.aws_caller_identity.current.account_id
}



